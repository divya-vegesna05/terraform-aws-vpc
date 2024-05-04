locals {
  name = "${var.Project_name}-${var.Environment}"
  azname = slice(data.aws_availability_zones.azs.names,0,2)
}