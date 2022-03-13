variable "vpc_cidr_block" {
  description = "cidr for VPC (eg 192.168.0.0/20)"
}

variable "public_subnet_config_map" {
  type = map(object({
    cidr_block = string   
  }))
  description = "A map of each public subnet to create, each one has a CIDR block"
}

variable "private_subnet_config_map" {
  type = map(object({
    cidr_block = string
  }))
  description = "A map of each private subnet to create, each one has a CIDR block"
  default = {}
}

variable "custom_subnet_config_map" {
  type = map(object({
    cidr_block = string
    routes = map(object({
      destination_cidr_block = string
      destination_type = string
    }))
  }))
  description = "A map of custom subnets to be created, each subnet has a map of routes and its CIDR block. Each route has a destination CIDR block and the destination type is either 'nat' or 'igw'"
  default = {}
}


