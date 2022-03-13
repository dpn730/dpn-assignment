# I've provided examples of level 1, level 2 and level 3 scenarios all using the same module.
# In level 3, you can try commenting out the private_subnet_config_map, the expected result is only level 1 will be deployed

module "vpc_level_1" {
    source = "./vpc"

    vpc_cidr_block = "192.166.0.0/16"

    public_subnet_config_map = {
        "pub01" = {
        cidr_block = "192.166.10.0/24"
        }

        "pub02" = {
        cidr_block = "192.166.90.0/24"
        }
    }
}

module "vpc_level_2" {
    source = "./vpc"

    vpc_cidr_block = "192.168.0.0/16"

    public_subnet_config_map = {
        "pub01" = {
        cidr_block = "192.168.10.0/24"
        }

        "pub02" = {
        cidr_block = "192.168.90.0/24"
        }
    }

    private_subnet_config_map = {
        "priv01" = {
        cidr_block = "192.168.20.0/24"
        }

        "priv02" = {
        cidr_block = "192.168.100.0/24"
        }
    }
}

module "vpc_level_3" {
    source = "./vpc"

    vpc_cidr_block = "192.167.0.0/16"

    public_subnet_config_map = {
        "pub01" = {
        cidr_block = "192.167.10.0/24"
        }

        "pub02" = {
        cidr_block = "192.167.90.0/24"
        }
    }

    private_subnet_config_map = {
        "priv01" = {
        cidr_block = "192.167.20.0/24"
        }

        "priv02" = {
        cidr_block = "192.167.100.0/24"
        }
    }

    custom_subnet_config_map = {
        "custom01" = {
            cidr_block = "192.167.30.0/24"
            routes = {
                "route1" = {
                    destination_cidr_block = "192.167.60.0/24"
                    destination_type = "nat"
                }
                "route2" = {
                    destination_cidr_block = "192.167.20.0/24"
                    destination_type = "nat"
                }
            }
        }
        "custom02" = {
            cidr_block = "192.167.60.0/24"
            routes = {
                "route1" = {
                    destination_cidr_block = "192.167.30.0/24"
                    destination_type = "nat"
                }
                "route2" = {
                    destination_cidr_block = "0.0.0.0/0"
                    destination_type = "igw"
                }
            }
        }
    }
}