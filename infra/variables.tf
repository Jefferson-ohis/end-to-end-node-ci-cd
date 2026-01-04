variable "aws_region" {
    default = "us-east-1"
}

variable "availability_zones" {
  type = list(string)
  description = "list of azs to use for vpc"
  default = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
  
}