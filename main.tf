provider "aws" {
  region  = "ap-south-1"         # Your AWS region
  profile = "technova-solution" # Your AWS CLI profile
}

resource "aws_key_pair" "technova_key" {
  key_name   = "technova-key"
  public_key = file("C:/Users/vaibh/.ssh/technova-key2.pub")
}

resource "aws_security_group" "technova_sg" {
  name        = "technova-node-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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

resource "aws_instance" "technova_ec2" {
  ami           = "ami-0cca134ec43cf708f" # Amazon Linux 2 AMI for ap-south-1
  instance_type = "t2.micro"
  key_name      = aws_key_pair.technova_key.key_name
  security_groups = [aws_security_group.technova_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              # Install Node.js
              curl -sL https://rpm.nodesource.com/setup_16.x | bash -
              yum install -y nodejs

              # Create Node.js app
              mkdir -p /home/ec2-user/app
              cd /home/ec2-user/app
              cat > server.js <<EOL
              const http = require('http');
              const hostname = '0.0.0.0';
              const port = 3000;
              const server = http.createServer((req, res) => {
                res.statusCode = 200;
                res.setHeader('Content-Type', 'text/plain');
                res.end('Hello, TechNova from Node.js!\\n');
              });
              server.listen(port, hostname, () => {
                console.log("Server running at http://" + hostname + ":" + port + "/");
              });
              EOL

              # Start Node.js app in background
              nohup node server.js > server.log 2>&1 &
              EOF

  tags = {
    Name = "TechNova-NodeJS"
  }
}

output "node_app_url" {
  value = "http://${aws_instance.technova_ec2.public_ip}:3000"
}