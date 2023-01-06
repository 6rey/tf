provider "aws" {
  region = var.aws_region
}

#Create security group with firewall rules
resource "aws_security_group" "my_security_group" {
  name        = var.security_group
  description = "security group for Ec2 instance"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # outbound from jenkis server
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags= {
    Name = var.security_group
  }
}

# Create AWS ec2 instance
resource "aws_instance" "aws-ubuntu-jen" {
  ami           = var.ami_id
  key_name = var.key_name
  instance_type = var.instance_type
  security_groups= [var.security_group]
    tags= {
    Name = var.tag_name
   }
   user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing Jenkins"
  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
  sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
  sudo apt update -y
  sudo apt install jenkins openjdk-11-jdk -y
  sudo systemctl start jenkins
  echo "*** Completed Installing jenkins"
  curl -sO http://91.92.136.187:8080/jnlpJars/agent.jar
  java -jar agent.jar -jnlpUrl http://91.92.136.187:8080/manage/computer/agent%2Djar/jenkins-agent.jnlp -secret bcf51f78fb24d6e0606ea62a83ca1b840d722956648c8d259920f059a8ad914e -workDir "/home/ubuntu/jenkins"
  EOF
}

# Create Elastic IP address
resource "aws_eip" "aws-ubuntu-jen" {
  vpc      = true
  instance = aws_instance.aws-ubuntu-jen.id
tags= {
    Name = "elastic_ip_ubu-jen"
  }
}


resource "aws_key_pair" "deployer" {
  key_name   = "ubuntu"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCa8Qa+rg0nmZ4MLzRN+MBFqj7StaCGj1P1y9bjnBuE2sYfU3Vrk2v9TPa6DueS2aq1ua+MHbmcPjAjHM0FRpXpTSW4xYYruLqzJlYghvMUBUnw/s+vz+JCTD9XgykfmQsUqpnNF5MLpLBa8GRICDEGQUOd4w1PBqvdLjZR4nYDkJ3fjRy9WO4FMzE2p1jdeexlMy+E7IKreoYxlV8foNAReEdQJNhg1pm2qUSUE3XzNfj4d9fRfuzUQLFfimcQNUmej3oHqBygl00HGi1I71uXmEveL9VBfXw+d+E+TWqtnQbahH1EtQfWbuDjpuXB1Rus8/yXcFVNLJTuItc5RtGl ubuntu@ip-172-31-8-251"

}