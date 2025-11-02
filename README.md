# Youtube videos used
[Tiny Tech Tutorials → AWS IAM Basics](https://www.youtube.com/watch?v=hAk-7ImN6iM)
[Sam Meech-Ward→Start using Terraform with AWS](https://www.youtube.com/watch?v=bStIFxbD1fo)

# Terraform commands used
* terraform init → Initialize tf project
* terraform apply → Will set up resources
* terraform state → has subcommands to manage state. terraform state list
    * terraform state list

      → aws_instance.webapp

    * terraform state show aws_instance.webapp

      → Will pull config details, such as public ip address, security group etc of aws_instance.webapp from AWS


* terraform fmt → prettify the tf file

* terraform init -upgrade → Update the version of TF