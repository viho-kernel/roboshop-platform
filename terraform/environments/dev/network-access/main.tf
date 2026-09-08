data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "roboshop-platform-tfstate-992989046853-ap-south-1"
    key    = "dev/network/terraform.tfstate"
    region = var.aws_region

    use_lockfile        = true
    allowed_account_ids = ["992989046853"]
  }
}

data "aws_route_table" "private_app_ops_subnet" {
  for_each = toset(concat(
    data.terraform_remote_state.network.outputs.private_app_subnet_ids,
    data.terraform_remote_state.network.outputs.private_ops_subnet_ids
  ))

  subnet_id = each.value
}

data "aws_route_table" "main" {
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

locals {
  private_route_table_ids = toset(concat(
    [
      for route_table in data.aws_route_table.private_app_ops_subnet :
      route_table.id
    ],
    [data.aws_route_table.main.id]
  ))
}

module "openvpn" {
  source = "../../../modules/openvpn"

  project_name              = var.project_name
  environment               = var.environment
  aws_region                = var.aws_region
  vpc_id                    = data.terraform_remote_state.network.outputs.vpc_id
  public_subnet_id          = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  private_route_table_ids   = local.private_route_table_ids
  vpn_client_cidr           = var.vpn_client_cidr
  allowed_vpn_ingress_cidrs = var.allowed_vpn_ingress_cidrs
}
