provider "aws" {
  region  = "ap-south-1"         # Change to your AWS region
  profile = "technova-solution" # Profile from AWS CLI
}

# Upload your public key to AWS
resource "aws_key_pair" "technova_key" {
  key_name   = "technova-key"
  public_key = file("C:/Users/vaibh/.ssh/technova-key2.pub")
}

# Create a Security Group to allow SSH and HTTP
resource "aws_security_group" "technova_sg" {
  name        = "technova-sg"
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
}

# Launch an EC2 instance
resource "aws_instance" "technova_ec2" {
  ami           = "ami-0cca134ec43cf708f" # Amazon Linux 2 AMI in ap-south-1
  instance_type = "t2.micro"
  key_name      = aws_key_pair.technova_key.key_name
  security_groups = [aws_security_group.technova_sg.name]

  tags = {
    Name = "TechNova-EC2"
  }
}

# Output the public IP
output "ec2_public_ip" {
  value = aws_instance.technova_ec2.public_ip
}