variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"
  }
variable "enable_dns_hostnames" {
  type = bool
  default = "true"
}
variable "common_tags" {
  type = map
  default = {}
}
variable "vpc_tags" {
  type = map
  default = {}
}
variable "Project_name" {
  type = string
  default = ""
}
variable "Environment" {
  type = string
  default = ""
}
variable "tags" {
  type = map
 default = {}
}
variable "igw_tags" {
  type = map
  default = {}
}
variable "public_cidr" {
  type = list
  validation {
    condition = length(var.public_cidr) == 2
    error_message = "Please give 2 subnets"
  }
}
variable "azname" {
    type = list
    default = []
}
variable "private_cidr" {
  type = list
  validation {
    condition = length(var.private_cidr) == 2
    error_message = "Please give 2 subnets"
  }
}
variable "database_cidr" {
  type = list
  validation {
    condition = length(var.database_cidr) == 2
    error_message = "Please give 2 subnets"
  }
}
variable "is_peering_required" {
  type = bool
 }
 variable "accepter_vpc" {
  type = string
  default = ""
 }