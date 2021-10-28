/* Lambada Upload */
resource "aws_lambda_function" "lambda_upload" {
  filename         = data.archive_file.lambda_upload_zip.output_path
  handler          = "lambda_upload"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "go1.x"
  function_name    = "filterit-lambda_upload"
  source_code_hash = data.archive_file.lambda_upload_zip.output_base64sha256

  environment {
    variables = {
      S3_BUCKET = var.image_bucket
    }
  }
}

/* Lambda Queue */
resource "aws_lambda_function" "lambda_queue" {
  filename         = data.archive_file.lambda_queue_zip.output_path
  handler          = "lambda_queue"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "go1.x"
  function_name    = "filterit-lambda_queue"
  source_code_hash = data.archive_file.lambda_queue_zip.output_base64sha256

  environment {
    variables = {
      AWS_IMAGE_TABLE = var.dynamodb_name
      AWS_SQS_QUEUE   = var.sqs_name
    }
  }
}

/* Lambda Feed*/
resource "aws_lambda_function" "lambda_feed" {
  filename         = data.archive_file.lambda_feed_zip.output_path
  handler          = "lambda_feed"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "go1.x"
  function_name    = "filterit-lambda_feed"
  source_code_hash = data.archive_file.lambda_feed_zip.output_base64sha256

  vpc_config {
    subnet_ids         = ["subnet-56490931", "subnet-58e32700", "subnet-2592e06c"]
    security_group_ids = ["sg-b9f38ec0"]
  }

  environment {
    variables = {
      AWS_IMAGE_TABLE   = var.dynamodb_name
      AWS_REDIS_ADDRESS = element(aws_elasticache_cluster.redis.cache_nodes, 0).address
    }
  }
}
