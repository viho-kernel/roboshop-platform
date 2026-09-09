module "ecr" {
  source = "../../../modules/ecr"

  project_name                  = var.project_name
  environment                   = var.environment
  repository_names              = var.repository_names
  untagged_image_retention_days = var.untagged_image_retention_days
  max_image_count               = var.max_image_count
}
