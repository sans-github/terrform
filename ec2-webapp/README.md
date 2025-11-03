# Resources created

| Resource Name | Purpose |
|---------------|---------|
| `tls_private_key.tf_ec2_key` | Generates a 4096-bit RSA private key for SSH authentication |
| `aws_key_pair.tf_ec2_key_pair` | Registers the public key with AWS for EC2 instance access |
| `local_file.tf_ec2_key_file` | Saves the private key locally to `~/.ssh/tf_ec2_key.pem` with secure permissions |
| `aws_security_group.sg_webapp_only_8080` | Firewall rules allowing SSH (port 22) and web app traffic (port 8080) from anywhere |
| `aws_instance.webapp` | Creates a t3.micro EC2 instance running the web application |

# Convenience scripts