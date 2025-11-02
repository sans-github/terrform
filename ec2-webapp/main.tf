resource "aws_instance" "webapp" {
  instance_type = "t3.micro"
  # https://aws.amazon.com/ec2/pricing/on-demand/?icmpid=docs_console_unmapped
  ami                    = "ami-0c1a6eb95aba250b6"
  vpc_security_group_ids = [aws_security_group.sg_webapp_only_8080.id]
  key_name               = aws_key_pair.aws_key_pair.key_name
  user_data = file("setup-app.sh")
}