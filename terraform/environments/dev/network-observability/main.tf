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

module "vpc_flow_logs" {
  source = "../../../modules/vpc-flow-logs"

  project_name          = var.project_name
  environment           = var.environment
  aws_region            = var.aws_region
  vpc_id                = data.terraform_remote_state.network.outputs.vpc_id
  log_retention_in_days = var.flow_log_retention_in_days
}
