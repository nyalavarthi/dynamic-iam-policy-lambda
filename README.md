This repo creates an IAM policy during deployment and attaches the policy to an existing IAM role.
This repo requires terraform workspaces knowledge.

Prerequisites : 
Dynamo DB table : ACCOUNT-TAGS


What resources this repo creates  ?

1. IAM role with dynamodb read permissions, this role will be used in the lambda to add permissions at run time.
2. Python Lambda : Lambda to create and add the IAM policy to the above role


Refer to this detailed documentation for more implementation detils and code explanation
 - http://i-cloudconsulting.com/create-iam-policies-using-aws-lambda/
 
 
terraform Commands to run the repo
Prior to running the commands, make sure to copy the AWS security tokens into command line.

For example from windows command line : 
 
```
set AWS_ACCESS_KEY_ID=....
set AWS_SECRET_ACCESS_KEY=....
set AWS_SESSION_TOKEN=.....


# command to initilize environment specific workspace ( dev, qa, prd)
# each env will have a separate backend config file
# terraform init -backend-config=backends/dev-env.tf
# terraform workspace new "dev" ( for creating new workspace) 
# terraform workspace select "dev" ( for selecting an existing workspace) 
# terraform plan
# terraform apply
```
