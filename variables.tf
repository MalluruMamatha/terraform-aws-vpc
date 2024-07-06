
## project related variables
variable "project_name" {
    type = string
  
}

variable "environment" {
    type = string
  
}

variable "common_tags" {
  type = map
}
## vpc related variables

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
  
}

variable "vpc_tags" {
  type = map
  default = {}
}

## IGW related variables
variable "igw_tags"{
    type = map
    default = {}

}

# public subnet related variables

variable "public_subnet_cidrs" {
  type = list
  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Please provide 2 valid public subnet CIDR"
  
}
}

variable "public_subnet_cidr_tags" {
  type = map
  default = {}
}

# private subnet related variables

variable "private_subnet_cidrs" {
  type = list
  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Please provide 2 valid private subnet CIDR"
  
}
}

variable "private_subnet_cidr_tags" {
  type = map
  default = {}
}

# Database subnet related variables

variable "database_subnet_cidrs" {
  type = list
  validation {
    condition     = length(var.database_subnet_cidrs) == 2
    error_message = "Please provide 2 valid database subnet CIDR"
  
}

}

variable "database_subnet_cidr_tags" {
  type = map
  default = {}
}

variable "database_subnet_group_tags" {
type = map
  default = {}
}

## NAT gateway variables

variable "nat_gateway_tags" {
  type = map
  default = {}
}

### public route table variables

variable "public_route_table_tags" {
  type = map
  default = {}
}

### private route table variables

variable "private_route_table_tags" {
  type = map
  default = {}
}

### database route table variables

variable "database_route_table_tags" {
  type = map
  default = {}
}

#### Peering ####
variable "is_peering_required" {
  type = bool
  default = false
}

variable "acceptor_vpc_id" {
  type = string
  default = ""
}

variable "vpc_peering_tags" {
  type = map
  default = {}
}