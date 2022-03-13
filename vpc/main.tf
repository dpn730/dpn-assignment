locals {
  #This code flattens the custom subnet maps in order to make filtering easier
  custom_routes = flatten([
    for subnet_key, subnet in var.custom_subnet_config_map : [
      for routes_key, routes in subnet.routes : {
        subnet_key       = subnet_key
        route_key       = routes_key
        cidr_block = subnet.cidr_block
        destination_cidr_block = routes.destination_cidr_block
        destination_type = routes.destination_type
      }
    ]
  ])

  # This filters the 'nat' destination type routes from the rest
  custom_routes_nat = {for gateway in local.custom_routes: 
               "${gateway.subnet_key}.${gateway.route_key}" => gateway if gateway.destination_type == "nat"}

  # This filters the 'igw' destination type routes from the rest
  custom_routes_igw = {for gateway in local.custom_routes: 
               "${gateway.subnet_key}.${gateway.route_key}" => gateway if gateway.destination_type == "igw"}
}

data "aws_region" "current" {}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
}

# Don't create internet gateway if there's no public subnets
resource "aws_internet_gateway" "main" {
  count = length(var.public_subnet_config_map) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id  
}

resource "aws_route_table" "main" {
  count = length(var.public_subnet_config_map) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }
}

resource "aws_main_route_table_association" "main" {
  count = length(var.public_subnet_config_map) > 1 ? 1 : 0
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main[0].id
}

# Public subnets use the main route table which routes 0.0.0.0 to internet gateway
resource "aws_subnet" "public" {
  for_each                = length(var.public_subnet_config_map) > 0 ? var.public_subnet_config_map : {}
  vpc_id                  = aws_vpc.main.id  
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = true 
}

# Private subnets are provisioned with their own NAT gateway and 0.0.0.0/0 is routed to the NAT gateway
# Private subnets won't be provisioned if there are no public subnets since they are needed for NAT gateway
resource "aws_subnet" "private" {
  for_each          = length(var.public_subnet_config_map) > 0 ? var.private_subnet_config_map : {}
  vpc_id            = aws_vpc.main.id    
  cidr_block        = each.value.cidr_block
}

resource "aws_eip" "nat" {
  for_each = length(var.public_subnet_config_map) > 0 ? var.private_subnet_config_map : {}
  vpc      = true
}

# Since they may be more private subnets compared to public subnets, 
# I used a modulo based on index to map each NAT gateway to an existing public subnet in a balanced way
resource "aws_nat_gateway" "private" {
  for_each      = length(var.public_subnet_config_map) > 0 ? var.private_subnet_config_map : {}
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[element(keys(aws_subnet.public), index(keys(var.private_subnet_config_map), each.key) % length(aws_subnet.public))].id
}

resource "aws_route_table" "private" {
  for_each = length(var.public_subnet_config_map) > 0 ? var.private_subnet_config_map : {} 
  vpc_id   = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private[each.key].id
  }    
}

resource "aws_route_table_association" "private" {
  for_each       = length(var.public_subnet_config_map) > 0 ? var.private_subnet_config_map : {}
  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = aws_subnet.private[each.key].id
}

# Custom subnets make use of the existing internet gateways
# Custom subnets won't be provisioned if there are no public and private subnets since they are needed for NAT gateway and internet gateway
resource "aws_subnet" "custom" {
  for_each          = length(var.public_subnet_config_map) > 0 && length(var.private_subnet_config_map) > 0 ? var.custom_subnet_config_map : {}
  vpc_id            = aws_vpc.main.id 
  # cidr_block        = var.private_subnet_config_map[each.key].cidr_block
  cidr_block        = each.value.cidr_block
}

resource "aws_route_table" "custom" {
  for_each = length(var.public_subnet_config_map) > 0 && length(var.private_subnet_config_map) > 0 ? var.custom_subnet_config_map : {}
  vpc_id   = aws_vpc.main.id
  
  # I used a modulo based on index to map each route to existing NAT gateway in a balanced way
  dynamic "route" {
    for_each = { for route_key, route_value in local.custom_routes_nat : route_key => route_value if route_value.subnet_key == each.key }

    content {
      cidr_block     = route.value.destination_cidr_block
      nat_gateway_id = aws_nat_gateway.private[element(keys(aws_nat_gateway.private), index(keys(var.custom_subnet_config_map), each.key) % length(aws_nat_gateway.private))].id
    }
  }

  dynamic "route" {
    for_each = { for route_key, route_value in local.custom_routes_igw : route_key => route_value if route_value.subnet_key == each.key }

    content {
      cidr_block     = route.value.destination_cidr_block
      gateway_id = aws_internet_gateway.main[0].id
    }
  }
}

resource "aws_route_table_association" "custom" {
  for_each       = length(var.public_subnet_config_map) > 0 && length(var.private_subnet_config_map) > 0 ? var.custom_subnet_config_map : {}
  route_table_id = aws_route_table.custom[each.key].id
  subnet_id      = aws_subnet.custom[each.key].id
}




