
terraform {
  required_version = "= 1.15.1"

  backend "s3" {
    bucket = "stuffed-toy-terraform-state-staging"
    region = "ap-northeast-1"
    # keyは環境で一意にすること
    key          = "staging/terraform.tfstate"
    profile      = "stuffed-toy-local-deployer-staging"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.43.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "virginia_no_tags"
  region  = "us-east-1"
  profile = var.aws_profile
}

provider "aws" {
  alias   = "ohio"
  region  = "us-east-2"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "california"
  region  = "us-west-1"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "oregon"
  region  = "us-west-2"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "mumbai"
  region  = "ap-south-1"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "osaka"
  region  = "ap-northeast-3"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "seoul"
  region  = "ap-northeast-2"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "singapore"
  region  = "ap-southeast-1"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "sydney"
  region  = "ap-southeast-2"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "central"
  region  = "ca-central-1"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "frankfurt"
  region  = "eu-central-1"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "ireland"
  region  = "eu-west-1"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "london"
  region  = "eu-west-2"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "paris"
  region  = "eu-west-3"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "stockholm"
  region  = "eu-north-1"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "saopaulo"
  region  = "sa-east-1"
  profile = var.aws_profile
  default_tags {
    tags = {
      env                                    = var.env_value_environment
      project                                = var.tag_project
      ChorusCost_Tag1                        = var.tag_project
      "${var.tag_cm_cost_billing_group_key}" = var.tag_cm_cost_billing_group_value
      Build                                  = "Terraform"
    }
  }
}
