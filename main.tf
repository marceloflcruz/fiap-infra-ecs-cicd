# ----------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------

####################################################
# VPC
####################################################
resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ecs-vpc"
  }
}

data "aws_availability_zones" "available" {}

####################################################
# Subnet
####################################################
resource "aws_subnet" "ecs_subnet" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block             = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-subnet"
  }
}

####################################################
# Internet Gateway + Route Table
####################################################
resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id
  tags = {
    Name = "ecs-igw"
  }
}

resource "aws_route_table" "ecs_route_table" {
  vpc_id = aws_vpc.ecs_vpc.id
  tags = {
    Name = "ecs-route-table"
  }
}

resource "aws_route" "ecs_route" {
  route_table_id         = aws_route_table.ecs_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ecs_igw.id
}

resource "aws_route_table_association" "ecs_rta" {
  subnet_id      = aws_subnet.ecs_subnet.id
  route_table_id = aws_route_table.ecs_route_table.id
}

####################################################
# Security Group (Open port 80 for example)
####################################################
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  vpc_id      = aws_vpc.ecs_vpc.id
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-sg"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "fiap-ecs-cluster"
}

####################################################
# IAM Role for the EC2 instance that runs ECS agent
####################################################
resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecs_instance_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

####################################################
# Attach the AmazonEC2ContainerServiceforEC2Role managed policy
####################################################
resource "aws_iam_role_policy_attachment" "ecs_instance_role_attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

####################################################
# Create the Instance Profile for the ECS EC2 instance
####################################################
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ecs_instance_role.name
}

####################################################
# Get the latest ECS-Optimized Amazon Linux 2 AMI
####################################################
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

####################################################
# EC2 Instance that joins the ECS cluster
####################################################
resource "aws_instance" "ecs_instance" {
  ami           = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  subnet_id             = aws_subnet.ecs_subnet.id

  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name

  # User Data to automatically join the instance to our ECS cluster
  user_data = <<-EOT
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config
EOT

  tags = {
    Name = "my-ecs-ec2-node"
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "my-ecs-task"
  network_mode             = "bridge"  # Common for EC2 tasks
  requires_compatibilities = ["EC2"]   # Important for EC2 launch type

  container_definitions = <<DEFINITION
[
  {
    "name": "my-container",
    "image": "nginx",
    "cpu": 256,
    "memory": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  # If your container needs to be accessible externally, 
  # ensure you have a public IP or a load balancer set up.
  # For a basic test, this is optional in EC2 mode, but typically recommended 
  # to place behind an ELB/ALB for production.
}
