#########################################################################################################
# Provider Variables
#########################################################################################################

variable "access_key" {
        description = "Access Key for AWS"
}
variable "secret_key" {
        description = "Secret Access Key for AWS"
}

#########################################################################################################
# General Variables
#########################################################################################################

variable "DD_API_KEY" {
    type        = string
    description = "Datadog API Key"
}

variable "name" {
    default     = "datadog-vector-demo"
    type        = string
    description = "Default name for this project"
}

variable "environment" {
    default     = "datadog-demo"
    type        = string
    description = "Default name for this environment"
}

variable "region" {
    default     = "us-east-1"
    type        = string
    description = "Default name for this region"
}

variable "ssh_pub_key" {
    type        = string
    description = "Public ssh key"
}

#########################################################################################################
# VPC Variables
#########################################################################################################

variable "vpc_cidr_block" {
    default     = "10.0.0.0/16"
    type        = string
    description = "Default CIDR block for the VPC"
}

variable "private_subnet_cidr_blocks" {
    default     = ["10.0.0.0/24"]
    type        = list(any)
    description = "Default list of list of private subnet CIDR blocks"
}

variable "public_subnet_cidr_blocks" {
    default     = ["10.0.127.0/24"]
    type        = list(any)
    description = "Default list of public subnet CIDR blocks"
}

variable "availability_zones" {
    default     = ["us-east-1a"]
    type        = list(any)
    description = "Default list of availability zones"
}

variable "tags" {
    default     = {}
    type        = map(string)
    description = "Extra tags to attach to resources"
}

#########################################################################################################
# Security Group Variables
#########################################################################################################



#########################################################################################################
# EC2 Group Variables
#########################################################################################################

variable "ami" {
    default     = "ami-08c40ec9ead489470"
    type        = string
    description = "Ubuntu as of 11-16-22"
}

variable "instance_type" {
    default     = "t3.micro"
    type        = string
    description = "EC2 Instance Type - https://aws.amazon.com/ec2/pricing/on-demand/"
}

variable "associate_public_ip_address" {
    default     = true
    type        = string
    description = "Default to setting a public IP unless you have a way into the private network"
}

variable "delete_on_termination" {
    default     = true
    type        = bool
    description = "Default to delete the EBS volume on termination"
}

variable "volume_size" {
    default     = "16"
    type        = number
    description = "Default volume size in GB"
}

variable "volume_type" {
    default     = "gp2"
    type        = string
    description = "Default volume type https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/general-purpose.html"
}
