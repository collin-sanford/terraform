# output "vpc_id" {
#   value       = aws_vpc.default.id
#   description = "VPC ID"
# }

# output "public_subnet_ids" {
#   value       = aws_subnet.public.*.id
#   description = "List public subnet IDs"
# }

# output "private_subnet_ids" {
#   value       = aws_subnet.private.*.id
#   description = "List private subnet IDs"
# }

# output "cidr_block" {
#   value       = var.vpc_cidr_block
#   description = "List VPC CIDR block"
# }

# output "nat_gateway_ips" {
#   value       = aws_eip.nat.*.public_ip
#   description = "List NAT gateways Elastic IPs"
# }

# output "ec2_ids" {
#   value       = aws_instance.*.id
#   description = "List EC2 IDs"
# }

output "ec2_public_IPs" {
  value         = aws_instance.ec2_agent_vector.*.public_ip
  description   = "List all EC2 Public IPs"
}

# output "ec2_global_ips" {
#   value       = ["${aws_instance.ec2_agent_vector.*.private_ip}"]
#   description = "List all EC2 Private IPs"
# }

output "my_public_IP" {
  value = local.myIP_json.ip
}

output "s3" {
  value         = aws_s3_bucket.datadog-vector-bucket.*.id
  description   = "List all AWS Buckets"
}

output "sqs_queue_id" {
  description   = "The URL for the created Amazon SQS queue"
  value         = aws_sqs_queue.vector-queue.id
}

# output "" {
#   value       = 
#   description = ""
# }

