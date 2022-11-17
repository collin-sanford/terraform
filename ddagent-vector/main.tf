#########################################################################################################
# VPC
#########################################################################################################

resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidr_blocks)
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "private" {
  count                  = length(var.private_subnet_cidr_blocks)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default[count.index].id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidr_blocks)
  vpc   = true
}

resource "aws_nat_gateway" "default" {
  depends_on    = [aws_internet_gateway.default]
  count         = length(var.public_subnet_cidr_blocks)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
}

#########################################################################################################
# Security Groups
#########################################################################################################

# This will fetch your local public IP address to lock down ssh to your
data "http" "myIP" {
  url = "https://ipinfo.io"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  myIP_json = jsondecode(data.http.myIP.response_body)
}

resource "aws_security_group" "ec2-sg" {
  name        = "${var.name}-ec2-sg"
  description = "Default EC2 Security Group"
  vpc_id      = aws_vpc.default.id

  # Allow SSH from your IP address
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["${local.myIP_json.ip}/32"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#########################################################################################################
# EC2 - Datadog agent + Vector installed on this instance
#########################################################################################################

resource "aws_key_pair" "ssh_pub_key" {
  key_name   = "ssh_pub_key"
  public_key = "${var.ssh_pub_key}"
}

resource "aws_instance" "ec2_agent_vector" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  count                       = 1
  subnet_id                   = aws_subnet.public[count.index].id
  associate_public_ip_address = true
  key_name                    = "ssh_pub_key"
  vpc_security_group_ids      = [aws_security_group.ec2-sg.id]
  root_block_device {
    delete_on_termination = "${var.delete_on_termination}"
    volume_size           = "${var.volume_size}"
    volume_type           = "${var.volume_type}"
  }
  user_data = <<-EOL
    #!/bin/bash -xe
    sudo apt update -y
    sudo apt upgrade -y
    DD_API_KEY="${var.DD_API_KEY}" DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"
    curl -1sLf 'https://repositories.timber.io/public/vector/cfg/setup/bash.deb.sh' | sudo -E bash
    sudo apt-get -y install vector
    
    # Vector Config
    printf '[sources.datadog-vector-demo]
    type = "aws_s3"
    region = "${var.region}"
    strategy = "sqs"
    sqs.queue_url = "${aws_sqs_queue.vector-queue.id}"
    auth.access_key_id = "${var.access_key}"
    auth.secret_access_key = "${var.secret_key}"

    [sinks.datadog]
    type = "datadog_logs"
    inputs = ["datadog-vector-demo"]
    default_api_key = "${var.DD_API_KEY}"
    compression = "gzip"' | sudo tee /etc/vector/vector.toml
    sudo systemctl start vector
    EOL
}

#########################################################################################################
# S3 - Bucket 
#########################################################################################################

resource "aws_s3_bucket" "datadog-vector-bucket"  {
  bucket = "${var.name}-bucket"
}

#########################################################################################################
# SQS/SNS
#########################################################################################################


resource "aws_sqs_queue" "vector-queue" {
  name   = "${var.name}-queue"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:${var.name}-queue",
      "Condition": {
        "ArnEquals": { "aws:SourceArn": "${aws_s3_bucket.datadog-vector-bucket.arn}" }
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.datadog-vector-bucket.id
  queue {
    queue_arn = aws_sqs_queue.vector-queue.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
