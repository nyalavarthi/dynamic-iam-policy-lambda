This repo creates an IAM policy during deployment and attaches the policy to an existing IAM role.
This repo requires terraform workspaces knowledge.

Prerequisites : 
Dynamo DB table : ACCOUNT-TAGS


What resources this repo creates  ?

1. IAM role with dynamodb read permissions, this role will be used in the lambda to add permissions at run time.
2. Python Lambda : Lambda to create and add the IAM policy to the above role


Refer to this detailed documentation for more implementation detils and code explanation
 - http://i-cloudconsulting.com/create-iam-policies-using-aws-lambda/
