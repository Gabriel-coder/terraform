module "vpc" {
  source          = "../../modules/vpc"
  cidr_block      = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  azs             = ["us-east-1a", "us-east-1b"]
  environment     = "dev"
}

resource "aws_security_group" "workstation_sg" {
  name        = "dev-workstation-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "dev-workstation-sg"
  }
}


module "ec2" {
  source             = "../../modules/ec2"
  ami_id             = "ami-08c40ec9ead489470" # Amazon Linux 2023 na us-east-1 (pode mudar)
  instance_type      = "t2.micro"
  subnet_ids         = module.vpc.private_subnet_ids
  key_name           = "terraform" # Deve ser uma key pair já criada na AWS
  environment        = "dev"
  security_group_ids = [aws_security_group.workstation_sg.id]
}

module "alb" {
  source       = "../../modules/alb"
  environment  = "dev"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.public_subnet_ids
  instance_ids = module.ec2.instance_ids
}

module "workstation" {
  source             = "../../modules/ec2"
  ami_id             = "ami-08c40ec9ead489470" # AMI Amazon Linux 2023
  instance_type      = "t2.micro"
  subnet_ids         = [module.vpc.public_subnet_ids[0]] # subnet pública
  key_name           = "terraform"                       # nome da sua Key Pair
  environment        = "dev"
  security_group_ids = [aws_security_group.workstation_sg.id]
}




