module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

# This block specifies the worker groups. 
# The instance types of each group are different just 
# in case the workloads require more resources

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 2
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# This block establishes the backend to be remote 
# It'll use and S3 bucket to store the state
# It'll use a Dynamo DB table to the lock file
# For this specific case they must be created in advance

terraform {
  backend "s3" {
    bucket         = "jm-tf-state"
    key            = "ekscluster/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "jm-tf-locks-table-eks"
  }
}