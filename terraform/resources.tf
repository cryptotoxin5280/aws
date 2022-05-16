/**
 * USER
 */
resource "aws_iam_user" "test_user" {
  name = "test_user"
}

resource "aws_iam_access_key" "test_user" {
  user = aws_iam_user.test_user.name
}

# resource "aws_iam_user_role_attachment" "user_policy" {
#   user = aws_iam_user.test_user.name
#   role = aws_iam_role.test_lambda_hello_role
# }

output "secret" {
  value = aws_iam_access_key.test_user.secret
  sensitive = true
}

/**
 * S3 BUCKET
 */
resource "aws_s3_bucket" "test_bucket" {
  bucket = "test-bucket"
}

resource "aws_iam_policy" "test_s3_policy" {
  name = "test_s3_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "s3:ListBucket"
      ]
      Effect = "Allow"
      Resource = [
        "arn:aws:s3:::test-bucket"
      ]
    },
    {
      Action = [
        "s3:GetObject"
      ]
      Effect = "Allow"
      Resource = [
        "arn:aws:s3:::test-bucket/*"
      ]
    }]
  })
}

/**
 * LAMBDA
 */
data "archive_file" "zip_lambda" {
  type        = "zip"
  source_dir  = "../lambda"
  output_path = "../hello_world.zip"
}

resource "aws_lambda_function" "hello_world" {
  function_name    = "HelloWorld"
  runtime          = "nodejs12.x"
  handler          = "src/hello.handler"
  filename         = "../hello_world.zip"
  source_code_hash = data.archive_file.zip_lambda.output_base64sha256
  role             = aws_iam_role.test_lambda_hello_role.arn
}

resource "aws_iam_role" "test_lambda_hello_role" {
  name = "test_lambda_hello_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "sts:AssumeRole"
      ]
      Principal = [{
        Service = "lambda.amazonaws.com"
      }]
      Effect   = "Allow"
    }]
  })
}

# resource "aws_iam_role_policy_attachment" "test_lambda-to-s3" {
#   role = aws_iam_role.test_lambda_hello_role.id
#   policy_arn = aws_iam_policy.test_s3_policy.arn
# } 
