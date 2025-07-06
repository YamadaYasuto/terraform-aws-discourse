resource "aws_network_interface" "this" {
  subnet_id       = var.subnet_id
  private_ips     = [var.ec2_private_ip]
  security_groups = [var.security_group_id]
}

# AMIからEC2インスタンス作成
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = "t2.xlarge"

  network_interface {
    network_interface_id = aws_network_interface.this.id
    device_index         = 0
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = "50"
  }

  iam_instance_profile = var.iam_role_ec2

  tags = {
    Name = var.ec2_name
  }
}
