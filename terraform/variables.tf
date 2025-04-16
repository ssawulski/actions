variable "vpc_cidr" {
  type = string
}

variable "docker_image" {
  type    = string
  default = "ssawulski/hello:latest"
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}
