provider "aws" {
  profile = "vveeo"
  region  = "ap-south-1" 
}

# Security Group for SSH and HTTP access
resource "aws_security_group" "k8s_sg_master" {
  name        = "k8s_security_group_master"
  description = "Allow SSH only"
  
  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "k8s-sg-master"
  }
}
resource "aws_security_group" "k8s_sg" {
  name        = "k8s_security_group_workernode"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "k8s-sg-worker"
  }
}

# Elastic IP for master node
resource "aws_eip" "k8s_master_eip" {
  instance = aws_instance.k8s_master.id
  domain      = "vpc"
  tags = {
    Name = "k8s-master-eip"
  }
}

# Elastic IP for worker nodes
resource "aws_eip" "k8s_worker_eip" {
  count    = 2
  instance = aws_instance.k8s_worker[count.index].id
  domain      = "vpc"
  tags = {
    Name = "k8s-worker-eip-${count.index + 1}"
  }
}

resource "aws_instance" "k8s_master" {
  ami                         = "ami-0838bc34dd3bae25e"
  instance_type               = "t2.medium"
  key_name                    = "k8s-cluster-manager"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.k8s_sg_master.name]

  tags = {
    Name = "k8s-master"
  }
}

resource "aws_instance" "k8s_worker" {
  count                       = 2
  ami                         = "ami-0838bc34dd3bae25e" 
  instance_type               = "t2.medium"
  key_name                    = "k8s-cluster-manager"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.k8s_sg.name]

  tags = {
    Name = "k8s-worker-${count.index + 1}"
  }
}

output "master_ip" {
  value = aws_eip.k8s_master_eip.public_ip
}

output "worker_ips" {
  value = aws_eip.k8s_worker_eip[*].public_ip
}
