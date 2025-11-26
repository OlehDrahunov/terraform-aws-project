module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${var.project_name}-vpc-${var.environment}"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway   = var.enable_nat_gateway
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Single NAT Gateway for cost optimization in dev
  single_nat_gateway = var.environment == "dev" ? true : false

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-vpc-${var.environment}"
      Environment = var.environment
    }
  )

  public_subnet_tags = {
    Name = "${var.project_name}-public-subnet"
    Type = "public"
  }

  private_subnet_tags = {
    Name = "${var.project_name}-private-subnet"
    Type = "private"
  }
}