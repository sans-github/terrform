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