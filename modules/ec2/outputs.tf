output "eni_ip" {
  value = aws_network_interface.this.private_ip
}