data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "roboshop-platform-tfstate-992989046853-ap-south-1"
    key    = "dev/network/terraform.tfstate"
    region = "ap-south-1"

    use_lockfile        = true
    allowed_account_ids = ["992989046853"]
  }
}
