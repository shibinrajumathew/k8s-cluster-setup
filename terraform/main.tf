provider "aws" {
  profile = "vveeo"
  region  = "ap-south-1"
}

# Create VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "k8s-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "k8s-igw"
  }
}

# Create Public Subnets in 3 Availability Zones
resource "aws_subnet" "k8s_subnet_a" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "k8s-subnet-a"
  }
}

resource "aws_subnet" "k8s_subnet_b" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "k8s-subnet-b"
  }
}

resource "aws_subnet" "k8s_subnet_c" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "k8s-subnet-c"
  }
}

# Create Route Table
resource "aws_route_table" "k8s_route_table" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }

  tags = {
    Name = "k8s-route-table"
  }
}

# Associate Subnets with Route Table
resource "aws_route_table_association" "subnet_a_association" {
  subnet_id      = aws_subnet.k8s_subnet_a.id
  route_table_id = aws_route_table.k8s_route_table.id
}

resource "aws_route_table_association" "subnet_b_association" {
  subnet_id      = aws_subnet.k8s_subnet_b.id
  route_table_id = aws_route_table.k8s_route_table.id
}

resource "aws_route_table_association" "subnet_c_association" {
  subnet_id      = aws_subnet.k8s_subnet_c.id
  route_table_id = aws_route_table.k8s_route_table.id
}

# Security Group for SSH and HTTP access
resource "aws_security_group" "k8s_sg_master" {
  vpc_id      = aws_vpc.k8s_vpc.id
  name        = "k8s_security_group_master"
  description = "Allow SSH only"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 10259
    to_port     = 10259
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
  vpc_id      = aws_vpc.k8s_vpc.id
  name        = "k8s_security_group_workernode"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 10256
    to_port     = 10256
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 30000
    to_port     = 32767
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

# Network Interface for Master Node
resource "aws_network_interface" "k8s_master_nic" {
  subnet_id   = aws_subnet.k8s_subnet_a.id
  private_ips = ["10.0.1.100"]
  attachment {
    instance     = aws_instance.k8s_master.id
    device_index = 1
  }
  tags = {
    Name = "k8s-master-nic"
  }
}


# Network Interface for Worker Nodes
resource "aws_network_interface" "k8s_worker_nic" {
  count     = 3
  subnet_id = element([aws_subnet.k8s_subnet_a.id, aws_subnet.k8s_subnet_b.id, aws_subnet.k8s_subnet_c.id], count.index)
  private_ips = [cidrhost(element([aws_subnet.k8s_subnet_a.cidr_block, aws_subnet.k8s_subnet_b.cidr_block, aws_subnet.k8s_subnet_c.cidr_block], count.index), 200)]
  attachment {
    instance     = aws_instance.k8s_worker[count.index].id
    device_index = 1
  }
  tags = {
    Name = "k8s-worker-nic-${count.index + 1}"
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
  count    = 3
  instance = aws_instance.k8s_worker[count.index].id
  domain      = "vpc"
  tags = {
    Name = "k8s-worker-eip-${count.index + 1}"
  }
}

resource "aws_instance" "k8s_master" {
  ami                         = "ami-0838bc34dd3bae25e"
  instance_type               = "t3.small"
  key_name                    = "k8s-cluster-manager"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.k8s_sg_master.id]
  subnet_id                   = aws_subnet.k8s_subnet_a.id # Assuming master in subnet_a

  tags = {
    Name = "k8s-master"
  }
}

resource "aws_instance" "k8s_worker" {
  count                       = 3
  ami                         = "ami-0838bc34dd3bae25e"
  instance_type               = "t3.small"
  key_name                    = "k8s-cluster-manager"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.k8s_sg.id]
  subnet_id                   = element([aws_subnet.k8s_subnet_a.id,aws_subnet.k8s_subnet_b.id, aws_subnet.k8s_subnet_c.id], count.index)

  tags = {
    Name = "k8s-worker-${count.index + 1}"
  }
}

# Print IPs
output "master_private_ip" {
  value = aws_instance.k8s_master.private_ip
}

output "worker_private_ips" {
  value = aws_instance.k8s_worker[*].private_ip
}

output "master_ip" {
  value = aws_eip.k8s_master_eip.public_ip
}

output "worker_ips" {
  value = aws_eip.k8s_worker_eip[*].public_ip
}
