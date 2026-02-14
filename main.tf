terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.32.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name = "terraform"

  tags = {
    Name = "${terraform.workspace == "prod" ? "HelloWorld-prod" : "HelloWorld-default"}"
  }
}

output "id_vm" {
  value = aws_instance.example.id
}

resource "null_resource" "name_motd" {
    provisioner "file" {
      source = "./file/motd"
      destination = "/tmp/motd"
    }
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("./terraform.pem")
      host = aws_instance.example.public_ip
    }
}

resource "null_resource" "name" {
  provisioner "remote-exec" {
    scripts = [ "./scripts/nginx.sh" ]
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("./terraform.pem")
    host = aws_instance.example.public_ip
  }
}

