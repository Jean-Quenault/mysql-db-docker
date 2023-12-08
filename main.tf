provider "aws" {
  region = "eu-west-3"
}

resource "aws_security_group" "instance_docker" {
  name        = "instance_docker"
  description = "Security Group for EC2 instance with Docker"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = "instance_docker"
  }
}


resource "aws_instance" "instance_docker" {
  ami           = "ami-0c95ddc49a2ac351f"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance_docker.name]
  user_data = base64encode(<<EOF
#!/bin/bash
yum update
yum install docker -y
yum install -y git
service docker start
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0c877eee92397ec69.efs.eu-west-3.amazonaws.com:/ docker-init
git clone https://github.com/Jean-Quenault/docker-init home/ec2-user/docker-init
cd home/ec2-user/docker-init
docker-compose -f docker-compose.yml up -d
EOF
                        )
  tags = {
    Name = "instance_docker"
  }
}


