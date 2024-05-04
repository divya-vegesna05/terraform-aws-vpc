resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peering_required ? 1 : 0
  peer_vpc_id   = var.accepter_vpc == "" ? data.aws_vpc.default.id : var.accepter_vpc
  vpc_id        = aws_vpc.module.id
  auto_accept  = var.accepter_vpc == "" ? true : false
  tags = {
    Name = "${local.name}"
  }
}
resource "aws_route" "accepter" {
  count = var.is_peering_required && var.accepter_vpc == "" ? 1 : 0
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}
resource "aws_route" "requester-public" {
  count = var.is_peering_required && var.accepter_vpc == "" ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}
resource "aws_route" "requester-private" {
  count = var.is_peering_required && var.accepter_vpc == "" ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}
resource "aws_route" "requester-database" {
  count = var.is_peering_required && var.accepter_vpc == "" ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}
