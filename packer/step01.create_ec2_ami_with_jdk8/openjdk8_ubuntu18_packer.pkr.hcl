variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "base_ami_id" {
  type    = string
  default = "ami-059e7332a087320a3"
}

variable "instance_type" {
  type    = string
  default = "m7g.2xlarge"
}

locals {
  ami_name = "ubuntu-18-04-openjdk8-arm64-graviton-8core"
}

source "amazon-ebs" "example" {
  region        = var.aws_region
  source_ami    = var.base_ami_id
  instance_type = var.instance_type
  ssh_username  = "ubuntu"
  ami_name      = local.ami_name
  ssh_timeout   = "10m"

  subnet_id = "subnet-04803b246f985198d"

  tags = {
    Name = "ubuntu-18-04-openjdk8-arm64-graviton-8core"
  }
}

build {
  sources = [
    "source.amazon-ebs.example"
  ]

  provisioner "shell" {
    inline = [
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo apt clean",
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "sudo apt install -y gnupg curl",
      "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9",
      "curl -O https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-3_all.deb",
      "sudo apt install ./zulu-repo_1.0.0-3_all.deb",
      "sudo apt update -y",
      "sudo apt install -y zulu8-jdk",
      "echo 'export JAVA_HOME=\"/usr/lib/jvm/zulu8-aarch64\"' >> ~/.bashrc",
      "echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc",
      "echo $JAVA_HOME",
      "javac -version"
    ]
  }
}

