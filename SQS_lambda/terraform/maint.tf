provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "terraformtfstatetest"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

###############################
# Lambda
###############################
data "archive_file" "sqs_lambda" {
  type        = "zip"
  source_file = "/home/maks/Learning/SQS_lambda/terraform/files/sqs_lambda.js"
  output_path = "/home/maks/Learning/SQS_lambda/terraform/files/sqs_lambda.js.zip"
}

resource "aws_lambda_function" "sqs_lambda" {
  function_name = "sqs_lambda"
  handler = "sqs_lambda.handler"
  role = "${aws_iam_role.example_lambda.arn}"
  runtime = "nodejs14.x"

  filename = "${data.archive_file.sqs_lambda.output_path}"
  source_code_hash = "${data.archive_file.sqs_lambda.output_base64sha256}"

  timeout = 30
  memory_size = 128
}

###############################
# SQS
###############################
resource "aws_sqs_queue" "test_sqs" {
  name = "TestSQS"
}

###############################
# Trigger
###############################
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 1
  event_source_arn  = "${aws_sqs_queue.test_sqs.arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.sqs_lambda.arn}"
}

