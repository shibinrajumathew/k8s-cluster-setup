provider "aws" {
  region = "ap-south-1"
}

# Define the key pair for SSH access
resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create a Security Group for Kubernetes Nodes
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-sg"
  description = "Allow traffic for Kubernetes nodes"

  # Allow inbound SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all traffic within the security group (e.g., between nodes)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-sg"
  }
}

# Create Elastic IPs for Master Nodes
resource "aws_eip" "master_nodes" {
  count = 2
}

# Create Elastic IPs for Worker Nodes
resource "aws_eip" "worker_nodes" {
  count = 3
}

# Create 2 master nodes with t3.micro instance type using Ubuntu
resource "aws_instance" "master_nodes" {
  count         = 2
  ami           = "ami-0b898040803850657" # Ubuntu 20.04 LTS AMI ID for Mumbai region
  instance_type = "t3.micro"
  key_name      = aws_key_pair.k8s_key.key_name
  security_groups = [aws_security_group.k8s_sg.name]

  tags = {
    Name = "k8s-master-${count.index + 1}"
  }

  # Adding some block storage (optional)
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
}

# Create 3 worker nodes with t3a.small instance type using Ubuntu
resource "aws_instance" "worker_nodes" {
  count         = 3
  ami           = "ami-0b898040803850657" # Ubuntu 20.04 LTS AMI ID for Mumbai region
  instance_type = "t3a.small"
  key_name      = aws_key_pair.k8s_key.key_name
  security_groups = [aws_security_group.k8s_sg.name]

  tags = {
    Name = "k8s-worker-${count.index + 1}"
  }

  # Adding some block storage (optional)
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
}

# Associate Elastic IPs with Master Nodes
resource "aws_network_interface_attachment" "master_nodes_eip" {
  count                 = 2
  instance_id           = aws_instance.master_nodes[count.index].id
  network_interface_id  = aws_instance.master_nodes[count.index].network_interface_ids[0]
  allocation_id         = aws_eip.master_nodes[count.index].id
}

# Associate Elastic IPs with Worker Nodes
resource "aws_network_interface_attachment" "worker_nodes_eip" {
  count                 = 3
  instance_id           = aws_instance.worker_nodes[count.index].id
  network_interface_id  = aws_instance.worker_nodes[count.index].network_interface_ids[0]
  allocation_id         = aws_eip.worker_nodes[count.index].id
}
