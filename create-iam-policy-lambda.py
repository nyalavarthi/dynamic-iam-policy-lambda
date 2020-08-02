import json
import boto3
import os

# Create IAM client
iam_client = boto3.client('iam')
from boto3.dynamodb.conditions import Key

#read important environment variables. - configured through terraform
dynamodb        = boto3.resource("dynamodb")
dynamo_table    = os.environ['MOSAIC_ACCOUNTS_TABLE']
role_name       = os.environ['IAM_ROLE_NAME']
policy_name     = os.environ['POLICY_NAME']
policy_arn      = os.environ['POLICY_ARN']

#handler method
def lambda_handler(event, context):
    table = dynamodb.Table(dynamo_table)    
    response = table.scan()['Items']
    # this string variable will be added to the policyStr which is a policy Document.
    role_arns = "" 
    for item in response:
        accountID = item["accountId"]
        iam_arn = "arn:aws:iam::"+accountID+":role/"+item["accountTag"]+"-CROSS-ACCOUNT-LAMBDA-ROLE"
        print (iam_arn)
        role_arns += "\""+iam_arn+"\","
    #remove extra comma at the end
    role_arns = role_arns[:-1]
    #String representing policy document
    policyStr = "{\r\n    \"Version\": \"2012-10-17\",\r\n    \"Statement\": [\r\n        {\r\n            \"Effect\": \"Allow\",\r\n            \"Action\": \"sts:AssumeRole\",\r\n            \"Resource\": [\r\n  "+role_arns+" \r\n            ]\r\n        }\r\n    ]\r\n}"
    
    iam = boto3.resource('iam')
    role = iam.Role(role_name)
    #detach policy if already exist
    try:
        role_res = role.detach_policy(PolicyArn=policy_arn)
    except Exception as e:
        print("An exception occurred detaching policy ", e)
        
    #delete the policy if already exists
    try:
        iam_client.delete_policy(PolicyArn=policy_arn)
    except Exception as e:
        print("An exception occurred deleting policy ", e)
    
    #Create new Policy
    response = iam_client.create_policy(
        PolicyName=policy_name,
        PolicyDocument=policyStr,
        Description="Test Policy Creation from Lambda function"
    )
    
    #attach the policy to Lambda role
    role_res = role.attach_policy(PolicyArn=policy_arn)
    print("role_res", role_res)
    
    return {
        'statusCode': 200,
        'body': json.dumps('Create IAM policy lambda complete!')
    }
