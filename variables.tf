
# Variables file implemented terraform workspaces using maps

variable "workspace_to_environment_map" {
  type = map
  default = {
    sbx = "sbx"
    dev = "dev"
    qa  = "qa"
    prd = "prd"
  }
}

# command to initilize environment specific workspace ( dev, qa, prd)
# each env will have a separate backend config file
# terraform init -backend-config=backends/sbx-env.tf
# terraform workspace new "dev"
# terraform plan
# terraform apply
locals {
  workspace_env = "${lookup(var.workspace_to_environment_map, terraform.workspace, "dev")}"
  #convert to uppercase 
  environment                   = "${upper(local.workspace_env)}"
  iam_policy_lambda_name        = "${local.environment}-IAM-CREATE-POLICY-LAMBDA"
  dynamo_table                  = "${local.environment}-ACCOUNT-TAGS"
}
