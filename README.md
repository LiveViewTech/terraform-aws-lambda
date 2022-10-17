Terraform AWS Lambda Function Component
Terraform module pattern to build a Lambda Function with Docker Container Image.

This module creates a Lambda Fucntion which will trigger by Cloud Watch Events. 



Usage
module "Lambda" {
  source = "bitbucket.org/liveviewtech/terraform-aws-lambda.git?"
  function_name = "example-fucntion"
  image_uri     = "${module.base.ecr_repository.repository_url}:${var.image_tag}"
  package_type  = "Image"
  



  private_subnet_ids            = module.acs.private_subnet_ids
  vpc_id                        = module.acs.vpc.id
  role_permissions_boundary_arn = module.acs.role_permissions_boundary.arn

  tags = {
    env  = "dev"
    repo = "https://bitbucket.org/liveviewtech/terraform-aws-lambda
  }
}
Created Resources
ECS Cluster (if not provided)
ECS Service
with security group
ECS Task Definition
with IAM role
CloudWatch Log Group
AutoScaling Target
AutoScaling Policies (one for stepping up and one for stepping down)
CloudWatch Metric Alarms (one for stepping up and one for stepping down)
Requirements
Terraform version 1.0.0 or greater
Inputs
Name	Type	Description	Default
name_prefix	string	optional string prefix to use on various resources to prevent collisions	null
function_name	string	Application name to name your Fargate API and other resources (Must be <= 24 alphanumeric characters)	
enable_container_insights	bool	Enables the capture of ECS Container Insights metrics.	true
task_policies	list(string)	List of IAM Policy ARNs to attach to the task execution IAM Policy	[]
task_cpu	number	CPU for the task definition	256
task_memory	number	Memory for the task definition	512
security_groups	list(string)	List of extra security group IDs to attach to the fargate task	[]
vpc_id	string	VPC ID to deploy the ECS fargate service and ALB	
private_subnet_ids	list(string)	List of subnet IDs for the fargate service	
role_permissions_boundary_arn	string	ARN of the IAM Role permissions boundary to place on each IAM role created		
log_retention_in_days	number	CloudWatch log group retention in days	120
tags	map(string)	A map of AWS Tags to attach to each resource created	

Object with following attributes to define the docker container(s) your fargate needs to run.

name - (Required) container name (referenced in CloudWatch logs, and possibly by other containers)
image - (Required) the ecr_image_url with the tag like: <acct_num>.dkr.ecr.us-west-2.amazonaws.com/myapp:dev or the image URL from dockerHub or some other docker registry
environment_variables - (Required) a map of environment variables to pass to the docker container
secrets - (Required) a map of secrets from the parameter store to be assigned to env variables
efs_volume_mounts - (Required) a list of efs_volume_mount objects to be mounted into the container.
Before running this configuration make sure that your ECR repo exists and an image has been pushed to the repo.

efs_volume_mount
Example

    efs_volume_mounts = [
      {
        name = "persistent_data"
        file_system_id = aws_efs_file_system.my_efs.id
        root_directory = "/"
        container_path = "/usr/app/data"
      }
    ]
name - A logical name used to describe what the mount is for.
file_system_id - ID of the EFS to mount.
root_directory - Source path inside the EFS.
container_path - Target path inside the container.
See the following docs for more details:


This module will create basic default autoscaling policies and alarms and you can define some variables of these default autoscaling policies.

min_capacity - (Required) Minimum task count for autoscaling (this will also be used to define the initial desired count of the ECS Fargate Service)
max_capacity - (Required) Maximum task count for autoscaling
Note: If you want to define your own autoscaling policies/alarms then you need to set this field to null at which point this module will not create any policies/alarms.

Note: the desired count of the ECS Fargate Service will be set the first time terraform runs but changes to desired count will be ignored after the first time.

CloudWatch logs
This module will create a CloudWatch log group named /fargate/<app_name> with log streams named <app_name>/<container_name>/<container_id>.

For instance with the above example the logs could be found in the CloudWatch log group: /fargate/example-api with the container logs in example-api/example/12d344fd34b556ae4326...

Outputs
Name	Type	Description

task_role	object	IAM role created for the tasks.
task_execution_role	object	IAM role created for the execution of tasks.