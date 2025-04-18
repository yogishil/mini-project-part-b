terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.93.0"
    }
  }
}

#provider "aws" {
  #access_key = ""
  #secret_key = ""
  #region = "ap-southeast-2"
#}

resource "aws_key_pair" "bikeshare_key" {
  key_name   = "bikeshare_key" 
  public_key = file("~/.ssh/id_rsa.pub") 
}

data "aws_ami" "latest_ubuntu"{
    most_recent = true
    
    owners = ["099720109477"] # Canonical
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
}

resource "aws_instance" "bikeshare_ec2" {
  ami = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.bikeshare_key.key_name
  security_groups = [aws_security_group.bikeshare_sg.name]
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [ 
        "sudo apt update -y",
        "sudo apt install -y docker.io",
        "mkdir actions-runner && cd actions-runner",
        "sudo curl -o actions-runner-linux-x64-2.323.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.323.0/actions-runner-linux-x64-2.323.0.tar.gz",
        "echo '0dbc9bf5a58620fc52cb6cc0448abcca964a8d74b5f39773b7afcad9ab691e19  actions-runner-linux-x64-2.323.0.tar.gz' | shasum -a 256 -c ",
        "tar xzf ./actions-runner-linux-x64-2.323.0.tar.gz",
        #"yes '' | ./config.sh --url https://github.com/yogishil/mini-project-part-b --token AOYFUGS37E7YIEAPE6NDFKLIAG37M",
        #"./run.sh &"

     ]
  }
  tags = {
    Name = "BikesharingAppInstance"
  }
  
}
resource "aws_security_group" "bikeshare_sg" {
    name = "bikeshare_sg"
    description = "Allow SSH and HTTP access"
  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
    from_port = "8001"
    to_port = "8001"
    protocol = "tcp"
    cidr_blocks=["0.0.0.0/0"]
  }
  egress  {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
  
}