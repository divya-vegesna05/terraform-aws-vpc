resource "aws_vpc" "module" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
      Name = local.name
    }
  )
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.module.id
  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
      Name = local.name
    }
  )
}
resource "aws_subnet" "public" {
  count = length(var.public_cidr)
  vpc_id     = aws_vpc.module.id
  cidr_block = var.public_cidr[count.index]
  availability_zone = local.azname[count.index]
  map_public_ip_on_launch = true
   tags = merge(
    var.common_tags,
    var.igw_tags,
    {
      Name = "${var.Project_name}-public-${local.azname[count.index]}"
    }
  )
}
resource "aws_subnet" "private" {
  count = length(var.private_cidr)
  vpc_id     = aws_vpc.module.id
  cidr_block = var.private_cidr[count.index]
  availability_zone = local.azname[count.index]
  tags = {
    Name = "${var.Project_name}-private-${local.azname[count.index]}"
  }
}
resource "aws_subnet" "database" {
  count = length(var.database_cidr)
  vpc_id     = aws_vpc.module.id
  cidr_block = var.database_cidr[count.index]
  availability_zone = local.azname[count.index]
  tags = {
    Name = "${var.Project_name}-database-${local.azname[count.index]}"
  }
}
resource "aws_eip" "eip" {
   domain   = "vpc"
   tags = {
    Name = "${local.name}"
  }
}
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${local.name}"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.module.id
  tags = {
    Name = "${var.Project_name}-public-route"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.module.id
  tags = {
    Name = "${var.Project_name}-private-route"
  }
}
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.module.id
  tags = {
    Name = "${var.Project_name}-database-route"
  }
}
resource "aws_route_table_association" "public-subnet" {
  count = length(var.public_cidr) 
  route_table_id = aws_route_table.public.id
  subnet_id      = element(aws_subnet.public[*].id,count.index)
}
resource "aws_route_table_association" "private-subnet" {
  count = length(var.private_cidr) 
  route_table_id = aws_route_table.private.id
  subnet_id      = element(aws_subnet.private[*].id,count.index)
}
resource "aws_route_table_association" "database-subnet" {
  count = length(var.database_cidr) 
  route_table_id = aws_route_table.database.id
  subnet_id      = element(aws_subnet.database[*].id,count.index)
}
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.example.id
}
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.example.id
}
resource "aws_db_subnet_group" "database" {
  name       = "${local.name}"
  subnet_ids = aws_subnet.database[*].id
  tags = {
    Name = "${local.name}-database"
  }
}