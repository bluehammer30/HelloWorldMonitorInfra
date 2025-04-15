resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name                                          = "private-${var.availability_zones[count.index]}"
      "kubernetes.io/cluster/${var.vpc_name}"       = "shared"
      "kubernetes.io/role/internal-elb"             = "1"
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name                                          = "public-${var.availability_zones[count.index]}"
      "kubernetes.io/cluster/${var.vpc_name}"       = "shared"
      "kubernetes.io/role/elb"                      = "1"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}

resource "aws_eip" "nat" {
  count = length(var.public_subnets)

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-nat-eip-${count.index}"
    }
  )
}

resource "aws_nat_gateway" "this" {
  count = length(var.public_subnets)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-nat-gw-${count.index}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-rt"
    }
  )
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-rt-${count.index}"
    }
  )
}

resource "aws_route" "private_nat_gateway" {
  count = length(var.private_subnets)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Security group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.vpc_name}-rds-sg"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-rds-sg"
    }
  )
}

# Security group for EKS
resource "aws_security_group" "eks" {
  name        = "${var.vpc_name}-eks-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-eks-sg"
    }
  )
}

# Allow EKS to communicate with RDS
resource "aws_security_group_rule" "eks_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.eks.id
  description              = "Allow EKS to communicate with RDS"
}
