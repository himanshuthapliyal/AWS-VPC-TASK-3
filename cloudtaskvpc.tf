provider "aws"{
  region = "ap-south-1"
  profile = "goel"
}

resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "myvpc1"
  }
}

resource "aws_subnet" "mysubnetpublic" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "mysubnet-1a"
  }
}
resource "aws_subnet" "mysubnetprivate" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "mysubnet-1b"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "myvpcgw"
  }
}
resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "MyGatewayRoute"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mysubnetpublic.id
  route_table_id = aws_route_table.r.id
}



/*
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.mysubnetprivate.id
  route_table_id = aws_route_table.r.id
}

*/



resource "aws_security_group" "wp-sg" {
  name        = "myterravpcfirewall"
  description = "Allow inbound traffic"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "sql-sg" {
  name        = "myvpcfirewall"
  description = "Allow inbound traffic"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    description = "MYSQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




resource "aws_instance" "os1" {
	ami = "ami-0c85d39b470a86c88"
	instance_type = "t2.micro"
	key_name = "fsociety"
	vpc_security_group_ids = [aws_security_group.wp-sg.id]
   // subnet_id = "subnet-0bc4c54f337c2d792"
  subnet_id="${aws_subnet.mysubnetpublic.id}"
tags = {
	Name = "WordPressOS"
	}
   }
resource "aws_instance" "os2" {
	ami = "ami-08706cb5f68222d09"
	instance_type = "t2.micro"
	key_name = "fsociety"
	vpc_security_group_ids = [aws_security_group.sql-sg.id]
    // subnet_id = "subnet-0e690e2c8d669d3bf"
       subnet_id="${aws_subnet.mysubnetprivate.id}"
     
tags = {
	Name = "MySqlOS"
	}
   }










