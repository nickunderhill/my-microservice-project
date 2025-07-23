variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)  
}

variable "availability_zones" {
  description = "Availability zones for VPC"
  type        = list(string)
}
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}