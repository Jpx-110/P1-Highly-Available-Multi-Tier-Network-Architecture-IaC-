#1. PROVIDER: Connects to nearest AWS region
provider "aws" {
  region = "eu-west-2"
}

# --- 2. VPC Creare a VPC with CIDR Block - this is the network perimter for our infrastructure
resource "aws_vpc" "main_vpc" {
    cidr_block              = "10.0.0.0/16"
    enable_dns_hostnames    = true
    tags = { Name = "P1-Highly Available Multi Tier Network Architecture" } 
}

# --- 3. Subnets > Public(Internet facing) and Private(secure) subnets
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    tags = { Name = "Public Subnet" }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = { Name = "Private-Subnet" }
}

# --- 4. INTERNET GATEWAY: The entry point
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# --- 5. ROUTE TABLE: Rules to send public traffic to the Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# --- 6. SECURITY GROUP: checks all network data/packets trying to access servers
resource "aws_security_group" "web_sg" {
  name        = "Web-Security-Group"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  # Inbound Rule: Allow HTTPS (Port 443) from anywhere
  ingress {
    description = "Allow Secure Web Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # The whole internet
  }

  # Outbound Rule: Allow everything OUT
  # This allows the server to fetch updates or talk to the database
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Represents ALL protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Web-SG" }
}



# --- 7. NAT GATEWAY (The "One-Way Mirror") ---
# Allows private resources to reach out for updates, but prevents the public traffic from internet reaching in.
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id # NAT Gateway MUST live in the Public Subnet
  tags          = { Name = "Main-NAT-Gateway" }
}

# --- 8. PRIVATE ROUTE TABLE ---
# Tells the Private Subnet: "If you need the internet, go through the NAT Gateway."
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# --- 9. BASTION HOST (The "Jump Box server") ---
# A secure entry point in the Public Subnet for Admin access. Think of like a side doorway to a bank vault for authorised personnel to acces without going through front reception
resource "aws_instance" "bastion_host" {
  ami           = "ami-0e8d228ad90af673b" # Amazon Linux 2023 AMI for London
  instance_type = "t2.micro"             # Free Tier eligible
  subnet_id     = aws_subnet.public.id
  
  # Attach the Security Group we built earlier
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "WMP-Bastion-Host"
  }
}