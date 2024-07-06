## creating vpc

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = merge(
    var.common_tags,
    var.vpc_tags,
    
  {
    Name = local.resource_name

  }
  )
}

## creating IGW and associated with vpc

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

tags = merge(
var.common_tags,
var.igw_tags,
{
    Name = local.resource_name
}
  )


}

# creating public subnets

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  availability_zone = local.azs_names[count.index]
  vpc_id     = aws_vpc.main.id
   map_public_ip_on_launch = true 
  cidr_block = var.public_subnet_cidrs[count.index]

  tags = merge(
var.common_tags,
var.public_subnet_cidr_tags,
{
  Name = "${local.resource_name}-public-${local.azs_names[count.index]}"
}
  )

}

# creating private subnets

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  availability_zone = local.azs_names[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]

  tags = merge(
var.common_tags,
var.private_subnet_cidr_tags,
{
  Name = "${local.resource_name}-private-${local.azs_names[count.index]}"
}
  )

}

# creating database subnets

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  availability_zone = local.azs_names[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]

  tags = merge(
var.common_tags,
var.database_subnet_cidr_tags,
{
  Name = "${local.resource_name}-database-${local.azs_names[count.index]}"
}
  )

}

## adding database subnets in one group

resource "aws_db_subnet_group" "db_group" {
  name       = "${local.resource_name}"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    var.database_subnet_group_tags,
    {
        Name = "${local.resource_name}"
    }
  )
}

## elastic ip creation

resource "aws_eip" "nat" {
  domain   = "vpc"
}

## NAT gateway creation

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

 tags = merge(
var.common_tags,
var.nat_gateway_tags,
{
  Name = "${local.resource_name}"
}
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw] 
  ### this means we are ensuring before creating NAT we must create IGW
}

### creating public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
var.common_tags,
var.public_route_table_tags,
{
  Name = "${local.resource_name}-public"
}
  )
}

### creating private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
var.common_tags,
var.private_route_table_tags,
{
  Name = "${local.resource_name}-private"
}
  )
}

### creating database route table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
var.common_tags,
var.database_route_table_tags,
{
  Name = "${local.resource_name}-database"
}
  )
}

### creating routs
## public route table ------route--------IGW
## Private,database route tables------route-------NAT

resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route" "database_route" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

#### route table and subnets association

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}