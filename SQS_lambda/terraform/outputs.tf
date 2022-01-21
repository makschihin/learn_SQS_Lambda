output "sqs_url" {
  value = "${aws_sqs_queue.test_sqs.id}"
}