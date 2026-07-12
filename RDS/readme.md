Add Final Project Structure
terraform-rds/

│

├── provider.tf

├── variables.tf

├── main.tf

├── network.tf

├── subnet.tf

├── security-group.tf

├── kms.tf

├── parameter-group.tf

├── option-group.tf

├── rds.tf

├── replica.tf

├── monitoring.tf

├── snapshot.tf

├── outputs.tf

└── terraform.tfvars
End with a "Cheat Sheet"
Resource                          Purpose

aws_db_instance                   Creates RDS

aws_db_subnet_group               Defines Database Subnets

aws_db_parameter_group            Database Parameters

aws_db_option_group               Database Features

aws_security_group                Controls Network Access

aws_kms_key                       Encryption

aws_db_snapshot                   Manual Backup

aws_db_proxy                      Connection Pooling

aws_db_event_subscription         Notifications

aws_cloudwatch_metric_alarm       Monitoring

aws_iam_role                      Enhanced Monitoring

aws_db_instance (Replica)         Read Replica
