# README #

Terraform AWS Lambda Function  module  to build a Lambda Function with Docker Container Image.

This module creates a Lambda Fucntion which will trigger by Cloud Watch Events.


This README would normally document whatever steps are necessary to get your application up and running.

### What is this repository for? ###

* Quick summary
* Version
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### How do I get set up? ###

Usage

module "lambda" {
  source = "./terraform-aws-lambda"

  image_uri     = "${module.base.ecr_repository.repository_url}:${var.image_tag}"
  package_type  = "Image"
  function_name = local.project.id
  tags = {
       env       = "dev"
    }
  private_subnet_ids = module.acs.private_subnet_ids
  security_groups = [
    module.acs.message_store_security_group.id,
    module.acs.horus_security_group.id,
  ]
  vpc_id = module.acs.vpc.id
  environment_variables = {
    LOG_LEVEL = "info"
    LOG_TAGS  = "_untagged,-data,messaging,entity_projection,entity_store,ignored,settings,cloudwatch"
    SSM_PARAMETER    = aws_ssm_parameter.message_store_url.name
   
  }
  role_permissions_boundary_arn = module.acs.role_permissions_boundary.arn
}


Created Resources:

Requirement:

Inputs:
Outputs:

