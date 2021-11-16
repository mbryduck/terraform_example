provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
  description = "inbound ports for ssh and standard http and everything outbound"
  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Terraform" = "true"
  }
}

# Data Block
# data "aws_ami" "redhat" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["RHEL-7.5_HVM_GA*"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#   owners = ["309956199498"]
# }

# Data Block
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Resource Block
resource "aws_instance" "jenkins_ubuntu" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_traffic.name]
  key_name        = "Jenkins_EC2_Key"

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install default-jdk-headless -y",
      "wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo add-apt-repository universe",
      "sudo apt-get update",
      "sudo apt-get install jenkins -y",
      "sudo systemctl start jenkins",
      "echo 'The initial password to unlock Jenkins is:'",
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
    ]
  }
  connection {
    type        = "ssh"
    host        = self.public_dns
    user        = "ubuntu"
    private_key = file(var.pem_file)
  }
  tags = {
    "Name" = "jenkins_ubuntu"
  }
}
