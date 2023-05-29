provider "aws" {
  
  region = "us-east-1"
  access_key = "xxxxx"
  secret_key = "xxxx"
}

locals {
  common_tags = {
    name = "custom_sg_rules_for_ec2"
  }
}
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.common_tags
}



resource "aws_instance" "ec2_instance" {
  
 ami = "ami-0715c1897453cabd1"
    instance_type = "t2.micro"
   tags = {
    Name = "single instance"
  }
 key_name = "terraform-keypair"
 vpc_security_group_ids = [aws_security_group.allow_tls.id]
 
 connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("./terraform-keypair.pem")
    host     = self.public_ip
  }

  provisioner "remote-exec" {
    on_failure = fail
     inline = [
        "sudo yum update -y" ,
        "sudo yum  install httpd -y",
        "sudo systemctl enable httpd.service",
        "sudo systemctl start httpd.service"

      ]
  }

}