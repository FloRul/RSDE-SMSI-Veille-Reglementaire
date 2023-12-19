locals {
  source_path         = "${path.module}/src/index.py"
  package_output_path = "${path.module}/${local.function_name}.zip"
  lambda_handler      = "index.lambda_handler"
  function_name       = "notification_sender"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/src/index.py"
  output_path = local.package_output_path
}

resource "aws_lambda_function" "notification_lambda" {
  function_name    = local.function_name
  handler          = local.lambda_handler
  runtime          = "python3.11"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = base64sha256(file("${path.module}/src/index.py"))
  role             = aws_iam_role.notification_sender_ses_role.arn
  timeout          = 20
  architectures    = ["x86_64"]
  environment {
    variables = {
      SES_FROM_EMAIL = aws_ses_email_identity.this.email
    }
  }
  provisioner "local-exec" {
    working_dir = path.module
    interpreter = ["PowerShell"]
    command     = <<-EOT
    rm ${local.function_name}.zip
    EOT
  }
}
