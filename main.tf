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
sudo yum update
sudo yum install docker -y
sudo yum install -y git
sudo service docker start
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo mkdir -p /home/ec2-user/dbdata
sudo git clone https://github.com/Jean-Quenault/docker-init
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0c877eee92397ec69.efs.eu-west-3.amazonaws.com:/ /home/ec2-user/dbdata
sudo docker-compose -f docker-compose.yml up -d
EOF
                        )
  tags = {
    Name = "instance_docker"
  }
}


