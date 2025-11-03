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