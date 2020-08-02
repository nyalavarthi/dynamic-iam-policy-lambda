#Lambda that comsumes data (bounced emails)  from SNS Topic and saves into DynamoDB table 
resource "aws_iam_role" "iam-policy-lambda_role" {
  name = "${local.environment}-IAM-CREATE-POLICY-LAMBDA-ROLE"
  tags = {
    Name       = "${local.environment}-IAM-CREATE-POLICY-LAMBDA-ROLE"
  }
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

resource "aws_iam_policy" "iam_lambda_policy" {
  name        = "${local.environment}-IAM-CREATE-POLICY-LAMBDA-POLICY"
  description = "This policy allows read permissions from DyamoDB and create IAM policies and attaches them to Roles"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Action": [
                "iam:CreatePolicy",
                "iam:ListPolicies",
                "iam:GetRole",
                "iam:DetachRolePolicy",
                "iam:GetPolicy",
                "iam:DeletePolicy",
                "iam:ListRoles",
                "iam:AttachRolePolicy"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:dynamodb:eu-central-1:${data.aws_caller_identity.current.account_id}:table/${local.dynamo_table}"
        },
         {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:eu-central-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.iam_policy_lambda_name}:*"
            ]
        }
                        
        ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "policy_attachement_iam_lambda" {
  policy_arn = aws_iam_policy.iam_lambda_policy.arn
  role       = aws_iam_role.iam-policy-lambda_role.name
}


resource "aws_lambda_function" "create-iam-policy-lambda" {
  filename      = "${path.module}/create-iam-policy-lambda.zip"
  function_name = local.iam_policy_lambda_name
  role          = aws_iam_role.iam-policy-lambda_role.arn
  handler       = "create-iam-policy-lambda.lambda_handler"
  timeout       = 60
  memory_size   = "1024"
  runtime       = "python3.8"
  description   = "Lambda function to create IAM policies and attach them to any given ROLE ARN"

  tags = {
    "Name"       = "${local.iam_policy_lambda_name}"
  }

  environment {
    variables = {
      MOSAIC_ACCOUNTS_TABLE = "${local.dynamo_table}"
      #Execution Role of the lambda which will be modified and added with a new policy via lambda
      IAM_ROLE_NAME         = aws_iam_role.other-lambda-role.name
      POLICY_NAME           = "${local.environment}-CROSS-ACCT-LAMBDA-POLICY"
      POLICY_ARN            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.environment}-CROSS-ACCT-LAMBDA-POLICY"
    }
  }
}

#Invoke lambda function
data "aws_lambda_invocation" "invoke_lambda" {
  function_name = local.iam_policy_lambda_name
  depends_on    =[aws_lambda_function.create-iam-policy-lambda]
  input         = <<JSON
{}
JSON
}
