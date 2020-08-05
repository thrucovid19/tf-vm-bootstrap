terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "aws" {
  version                 = "~> 2.0"
  shared_credentials_file = var.credentials
  region                  = var.region
}

locals {
  common_tags = {
    owner = "QA"
  }
}

module "vmseries" {
  source                 = "github.com/thrucovid19/tf-vm-bootstrap"
  authcode               = "thistest"
  bootstrap_s3bucket     = "bootup"
  panorama1              = "10.155.1.11"
  panorama2              = "10.155.1.12"
  hostname               = "vmfirewal"
  panorama_bootstrap_key = "example"
  template               = "tmplstack"
  devicegroup            = "dgtest"
  region                 = var.region
  tags                   = local.common_tags
}

output "vm-series-eip" {
  value = module.vmseries.eip
}
