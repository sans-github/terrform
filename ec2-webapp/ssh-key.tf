# Generate an SSH key locally
resource "tls_private_key" "tf_ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register the public key with AWS
resource "aws_key_pair" "tf_ec2_key_pair" {
  key_name   = "tf_ec2_key"
  public_key = tls_private_key.tf_ec2_key.public_key_openssh
}

# Output private key for local use
output "private_key_pem" {
  value     = tls_private_key.tf_ec2_key.private_key_pem
  sensitive = true
}

# Save the private key inside ~/.ssh and set 400 permission
resource "local_file" "tf_ec2_key_file" {
  content         = tls_private_key.tf_ec2_key.private_key_pem
  filename        = "${pathexpand("~/.ssh/tf_ec2_key.pem")}"
  file_permission = "0400"
}