output "vpc_id" {
  value = aws_vpc.main.id
}

output "cidr_block" {
  value = var.vpc_cidr_block
}

output "igw_id" {
  value = length(aws_internet_gateway.main) > 0 ? aws_internet_gateway.main[0].id : null
}

output "main_rtb_id" {
  description = "Main routing table Id"
  value       = length(aws_route_table.main) > 0 ? aws_route_table.main[0].id : null
}