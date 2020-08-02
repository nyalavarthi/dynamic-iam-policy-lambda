#Lambda execution role for any lambda, we use this role for the demo purposes. 
#This role will be updated via create-iam-policy-lambda and a new policy will be added dynamically
resource "aws_iam_role" "other-lambda-role" {
  name = "${local.environment}-OTHER-LAMBDA-ROLE"
  tags = {
    Name       = "${local.environment}-OTHER-LAMBDA-ROLE"
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

resource "aws_iam_policy" "other_policy" {
  name        = "${local.environment}-OTHER-LAMBDA-POLICY"
  description = "This policy allows read permissions from DynamoDB "

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
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
                "arn:aws:logs:eu-central-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/guardduty_to_s3:*"
            ]
        }
                        
        ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "policy_attachement_ses" {
  policy_arn = aws_iam_policy.other_policy.arn
  role       = aws_iam_role.other-lambda-role.name
}
