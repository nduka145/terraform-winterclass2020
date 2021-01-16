provider "aws" {
  region     = "us-east-1"
}

resource "aws_vpc" "devvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "New-VPC"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.devvpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "dev-privateSubnet "
  }
}


resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.devvpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "dev-publicSubnet"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.devvpc.id

  tags = {
    Name = "devgw"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.devvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "devvpcroute"
  }
}


resource "aws_route_table_association" "association1" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.route.id
}


resource "aws_route_table_association" "association2" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route.id
}



resource "aws_security_group" "devsg" {
  name        = "devsg"
  description = "Allow TLS inbound traffic 22"
  vpc_id      = aws_vpc.devvpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devsg"
  }
}


resource "aws_instance" "web" {
  ami           = "ami-000db10762d0c4c05"
  instance_type = "t2.micro"
  key_name   = "classkey"
  subnet_id      = "${aws_subnet.public.id}"
  security_groups    =  [aws_security_group.devsg.id]

  tags = {
    Name = "webinstance"
  }
}
