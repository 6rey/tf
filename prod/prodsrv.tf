provider "aws" {
   profile = "default"
   region = "eu-central-1"
   shared_credentials_file = "E:/terraform/tf2/.aws/credentials"
}

#### Create EC2 instance with istall jenkins

resource "aws_instance" "aws-ubuntu-prod" {
   ami = "ami-03fbd36aaa3d9d134"
   instance_type = "t3.micro"
   key_name = "prodsrv"
   vpc_security_group_ids = [aws_security_group.test_aws_sec2.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing Jenkins"
  wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
  sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
  sudo apt update -y
  sudo apt install docker.io openjdk-11-jdk -y
  sudo snap install docker
  sudo systemctl start docker
  echo "*** Completed Installing java and docker"
  curl -sO http://91.92.136.187:8080/jnlpJars/agent.jar
  java -jar agent.jar -jnlpUrl http://91.92.136.187:8080/manage/computer/prod%2Dsrv/jenkins-agent.jnlp -secret 22381d99ff0392d0f066b1a8c10e092b16b0683425b24ef436d4079603702414 -workDir "/home/jenkins"
  EOF

}

######Create an Elastic IP
resource "aws_eip" "demo-eip" {
  vpc = true
}

#Associate EIP with EC2 Instance
resource "aws_eip_association" "demo-eip-association" {
  instance_id   = aws_instance.aws-ubuntu-prod.id
  allocation_id = aws_eip.demo-eip.id
}

output "elastic_ip" {
  value = aws_eip.demo-eip.public_ip
}
### Create sec group

resource "aws_security_group" "test_aws_sec2" {
  name        = "prod  server1"
  description = "prod server for application"


  ingress {
    description      = "open port 8080"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  ingress {
    description      = "open port 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  ingress {
    description      = "open ports 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_8080"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "prodsrv"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCykblZMCs3q8r6nbSq28u6SSJP/RtgqfpRr5TSGdKi6YgO8ISXNQkltamK7XowVub//DSMMKONxl9a2FVVmwVAjYbWEgVyueXAJDS3an/yUD0v+Tz3tlR7cNK+vq/b8pJLmybY23FUwo39orVigmDQxa9N9XnFeOjx798+y5C++gBY3kgQ1FMXFHEEX01uVXsbuRlJzP3XTCMbDz4dldV6o7DKDwtBuM29V3aRlzC7w7N5De1v8+7KGu53cri/m1KPyhucVU8kxfsc/NncmJ1wl8HFsL4UfMFu9EwdPRVPE/dnjhJQa+Ss9MwzgR4lRwnZnoc7SGaMZVp2zrFf7Sbd prodsrv"

}
