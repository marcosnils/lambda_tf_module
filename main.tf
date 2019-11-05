variable "function_name" {
  type = "string"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda_${var.function_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "${var.function_name}"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "index.test"

  source_code_hash = "${filebase64sha256("${path.module}/lambda_function_payload.zip")}"

  runtime = "nodejs10.x"

  depends_on = ["null_resource.deps_validation"]
}

resource "null_resource" "deps_validation" {
  triggers = {
    authorizer_hash = "${filebase64sha256("${path.module}/lambda_function_payload.zip")}"
  }

  provisioner "local-exec" {
    # Checks that node_modules is inside zip file
    command = "unzip -l ${path.module}/lambda_function_payload.zip | grep figlet > /dev/null"
  }
}
