# Create a VPC
resource "aws_vpc" "homelab_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "Cybersecurity Homelab VPC"
  }

}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = "${aws_vpc.homelab_vpc.id}"
  cidr_block = var.public_subnet_cidr

  tags = {
    Name = "Cybersecurity Homelab Public Subnet"
  }

}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.homelab_vpc.id}"

  tags = {
    Name = "Cybersecurity Homelab IGW"
  }

}

# Create Route Table
resource "aws_route_table" "route-table" {
  vpc_id = "${aws_vpc.homelab_vpc.id}"
  
}

# Create Route to IGW in Route Table
resource "aws_route" "internet" {
  route_table_id         = "${aws_route_table.route-table.id}"
  destination_cidr_block = "0.0.0.0/0" # Replace with your VPC CIDR block
  gateway_id       = "${aws_internet_gateway.igw.id}"
}

# Associate Route Table to Public Sunet
resource "aws_route_table_association" "subnet_association" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.route-table.id}"
}

# Create Security Group for Windows 10 and Kali Linux Instances.
resource "aws_security_group" "win-kali-security-group" {
  name_prefix = "win-kali-"
  description = "Example security group allowing SSH, RDP, and ICMP"
  vpc_id = "${aws_vpc.homelab_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1  # ICMP type and code (-1 means all)
    to_port     = -1  # ICMP type and code (-1 means all)
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
    Name = "Cybersecurity Homelab Windows / Kali Security Group"
  }

}

# Create Security Group for Linux Security Tools Instance.
resource "aws_security_group" "linux-security-tools" {
  name_prefix = "security-tools-"
  description = "Ingress and egress rules for Security Tools Box"
  vpc_id = "${aws_vpc.homelab_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1  # ICMP type and code (-1 means all)
    to_port     = -1  # ICMP type and code (-1 means all)
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5900
    to_port     = 5920
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9997
    to_port     = 9997
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
    Name = "Cybersecurity Homelab Linux Security Tools Security Group"
  }

}

# Create Windows Instance.
resource "aws_instance" "windows" {
  ami = "ami-060b1c20c93e475fd"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public_subnet.id}"

  key_name = var.aws-key

  security_groups = ["${aws_security_group.win-kali-security-group.id}"]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30 # Specify the desired size in GB
  }

  tags = { 
    Name = "Cybersecurity Homelab [Windows 10]"
  }

}

# Crate Kali Attacker Instance.
resource "aws_instance" "kali" {
  ami = "ami-0b02670313196539c" 
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public_subnet.id}"

  key_name = var.aws-key

  security_groups = ["${aws_security_group.win-kali-security-group.id}"]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 12 # Specify the desired size in GB
  }

  tags = { 
    Name = "Cybersecurity Homelab [Kali]"
  }

}

# Create Security Tools Instance.
resource "aws_instance" "security-tools" {
  ami = "ami-0901bbd9d6e996fb7"
  instance_type = "t3.large"
  subnet_id = "${aws_subnet.public_subnet.id}"

  key_name = var.aws-key

  security_groups = ["${aws_security_group.linux-security-tools.id}"]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30 # Specify the desired size in GB
  }

  tags = { 
    Name = "Cybersecurity Homelab [Security Tools]"
  }

}

# Output Windows IP Address.
output "instance_public_ip_win" {
  value = "Windows Box IP Address: ${aws_instance.windows.public_ip}"
}

# Output Kali IP Address.
output "instance_public_ip_kali" {
  value = "Kali Box IP Address: ${aws_instance.kali.public_ip}"
}

# Output Security Tools IP Address.
output "instance_public_ip_security-tools" {
  value = "Security Tools Box IP Address: ${aws_instance.security-tools.public_ip}"
}