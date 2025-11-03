resource "aws_s3_bucket" "aws_s3_bucket" {
  bucket = var.s3_bucket
  force_destroy = true
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