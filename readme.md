# Getting Started
This repo will deploy a VPC, private subnets, public subnets, security groups S3 bucket, SQS, an Ubuntu VM with the Datadog Agent and Vector configured. The security group associated with the aws_instance will only allow 22/tcp from your local public IP address. Relevant variables will output upon successful deployment of resources. 

This repo requires the following:
- AWS Account with appropriate permissions
    - Access/Secret Access Key
- Terraform installed
- You will need to create terraform.tfvars. terraform.tfvars should include your AWS key/secret

You will need to create terraform.tfvars in the directory that you are using to deploy resources with the following values:
- `access_key` = "<AWS_ACCESS_KEY"
- `secret_key` = "<AWS_SECRET_KEY>"
- `DD_API_KEY` = "<DATADOG_API_KEY>"
- `ssh_pub_key` = "<YOUR_PUBLIC_SSH_KEY>"

# Deployment
1. Nagivate to the agent-vector directory
2. Initiliaze the Terraform providers with: `terraform init`
3. Preview the Terraform actions wtih: `terraform plan`
4. Execute the actions proposed in terraform plan with: `terraform apply`

# Other Terraform Commands
- You can destroy specific resources by running: `terraform destroy --target <resource>.<resource_name>`
- You can destroy all resources by running: `terraform destroy`