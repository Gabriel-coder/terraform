resource "aws_instance" "this" {
  count         = length(var.subnet_ids)
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_ids[count.index]
  key_name      = var.key_name
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name = "${var.environment}-ec2-${count.index + 1}"
  }
}
