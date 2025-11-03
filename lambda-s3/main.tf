resource "aws_s3_bucket" "aws_s3_bucket" {
  bucket = var.s3_bucket
}


# IAM Role for Lambda with a trust policy that allows Lambda to assume it
resource "aws_iam_role" "miniflix_lambda_role" {
  name = "miniflix-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach S3 Read-Only Access Policy
resource "aws_iam_role_policy_attachment" "s3_readonly" {
  role       = aws_iam_role.miniflix_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Attach Basic Lambda Execution Policy (for CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.miniflix_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# Lambda requires a zip file - there's no way around it. AWS doesn't accept raw .py files.
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda Function
resource "aws_lambda_function" "miniflix" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "miniflix-lambda"
  role          = aws_iam_role.miniflix_lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.13"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# S3 bucket notification to trigger Lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.aws_s3_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.miniflix.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

# Permission for S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.miniflix.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.aws_s3_bucket.arn
}