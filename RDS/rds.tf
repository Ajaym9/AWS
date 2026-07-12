



################################################################################
#  Part 1: Master aws_db_instance Resource (All Important Parameters, Hardcoded)#
##################################################################################

resource "aws_db_instance" "mysql" {

  ###############################################################
  # General Configuration
  ###############################################################

  identifier                     = "mysql-db"                     # ✅ Required
  engine                         = "mysql"                        # ✅ Required
  engine_version                 = "8.0.39"                       # ⭐ Recommended
  instance_class                 = "db.t4g.micro"                 # ✅ Required

  ###############################################################
  # Database Configuration
  ###############################################################

  db_name                        = "employee_db"                  # 🔹 Optional
  username                       = "admin"                        # ✅ Required
  password                       = "Admin@123"                   # ✅ Required (If Secrets Manager is not used)

  manage_master_user_password    = false                          # 🔹 Optional (true = AWS Secrets Manager)

  ###############################################################
  # Storage Configuration
  ###############################################################

  allocated_storage              = 20                             # ✅ Required
  storage_type                   = "gp3"                          # ⭐ Recommended
  max_allocated_storage          = 100                            # 🔹 Optional (Storage Autoscaling)

  storage_encrypted              = true                           # ⭐ Recommended
  kms_key_id                     = aws_kms_key.rds_key.arn        # 🔹 Optional

  ###############################################################
  # Availability & Durability
  ###############################################################

  multi_az                       = true                           # ⭐ Recommended

  availability_zone              = "us-east-1a"                   # 🔹 Optional (Only for Single-AZ)

  ###############################################################
  # Network Configuration
  ###############################################################

  publicly_accessible            = false                          # ⭐ Recommended

  network_type                   = "IPV4"                         # 🔹 Optional

  db_subnet_group_name           = aws_db_subnet_group.mysql_subnet.name   # ⭐ Recommended

  vpc_security_group_ids = [
    aws_security_group.mysql_sg.id
  ]                                                                # ⭐ Recommended

  ###############################################################
  # Database Groups
  ###############################################################

  parameter_group_name           = aws_db_parameter_group.mysql_parameter.name   # 🔹 Optional

  option_group_name              = aws_db_option_group.mysql_option.name         # 🔹 Optional

  ###############################################################
  # Backup Configuration
  ###############################################################

  backup_retention_period        = 7                              # ⭐ Recommended

  preferred_backup_window        = "04:00-05:00"                  # 🔹 Optional

  copy_tags_to_snapshot          = true                           # 🔹 Optional

  delete_automated_backups       = true                           # 🔹 Optional

  ###############################################################
  # Maintenance
  ###############################################################

  auto_minor_version_upgrade     = true                           # ⭐ Recommended

  preferred_maintenance_window   = "sat:03:00-sat:04:00"          # 🔹 Optional

  allow_major_version_upgrade    = false                          # 🔹 Optional

  apply_immediately              = false                          # 🔹 Optional

  ###############################################################
  # Monitoring
  ###############################################################

  monitoring_interval            = 60                             # 🔹 Optional

  monitoring_role_arn            = aws_iam_role.rds_monitoring.arn   # 🔹 Optional

  performance_insights_enabled   = true                           # ⭐ Recommended

  performance_insights_retention_period = 7                       # 🔹 Optional

  enabled_cloudwatch_logs_exports = [
    "error",
    "general",
    "slowquery"
  ]                                                               # 🔹 Optional

  ###############################################################
  # Authentication
  ###############################################################

  iam_database_authentication_enabled = true                      # 🔹 Optional

  ###############################################################
  # SSL
  ###############################################################

  ca_cert_identifier             = "rds-ca-rsa2048-g1"            # 🔹 Optional

  ###############################################################
  # Deletion Protection
  ###############################################################

  deletion_protection            = true                           # ⭐ Recommended

  skip_final_snapshot            = true                           # ⭐ Recommended (Lab)

  # final_snapshot_identifier    = "mysql-final-backup"
  # 🔹 Optional (Production)

  ###############################################################
  # Character Set
  ###############################################################

  character_set_name             = "utf8mb4"                      # 🔹 Optional

  ###############################################################
  # License
  ###############################################################

  license_model                  = "general-public-license"       # 🔹 Optional

  ###############################################################
  # Port
  ###############################################################

  port                           = 3306                           # 🔹 Optional

  ###############################################################
  # Tags
  ###############################################################

  tags = {

    Name        = "mysql-db"

    Environment = "Production"

    Project     = "HRMS"

    Owner       = "CloudTeam"

  }

}

################################################################################
#                               2. DB Subnet Group                              #
##################################################################################


resource "aws_db_subnet_group" "mysql_subnet" {

  ###################################################
  # General
  ###################################################

  name        = "mysql-db-subnet-group"           # ✅ Required

  description = "Private Subnets for MySQL"       # 🔹 Optional

  ###################################################
  # Subnets
  ###################################################

  subnet_ids = [

    aws_subnet.private_subnet_1.id,

    aws_subnet.private_subnet_2.id

  ]                                               # ✅ Required (Minimum 2 AZs)

  ###################################################
  # Tags
  ###################################################

  tags = {

    Name = "mysql-db-subnet-group"

    Environment = "Production"

  }                                               # 🔹 Optional

}

. Security Group
resource "aws_security_group" "mysql_sg" {

  ###################################################
  # General
  ###################################################

  name        = "mysql-security-group"          # ✅ Required

  description = "Allow MySQL Access"            # 🔹 Optional

  vpc_id      = aws_vpc.main.id                 # ✅ Required

  ###################################################
  # Inbound Rule
  ###################################################

  ingress {

    description = "Allow MySQL from EC2"        # 🔹 Optional

    from_port = 3306                           # ✅ Required

    to_port   = 3306                           # ✅ Required

    protocol  = "tcp"                          # ✅ Required

    security_groups = [

      aws_security_group.ec2_sg.id

    ]                                          # ⭐ Recommended

  }

  ###################################################
  # Outbound Rule
  ###################################################

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [

      "0.0.0.0/0"

    ]

  }

  ###################################################
  # Tags
  ###################################################

  tags = {

    Name = "mysql-security-group"

  }

}
4. Parameter Group
resource "aws_db_parameter_group" "mysql_parameter" {

  ###################################################
  # General
  ###################################################

  name   = "mysql-parameter-group"          # ✅ Required

  family = "mysql8.0"                       # ✅ Required

  ###################################################
  # Parameters
  ###################################################

  parameter {

    name  = "max_connections"

    value = "200"

  }

  parameter {

    name = "binlog_format"

    value = "ROW"

  }

  parameter {

    name = "innodb_flush_log_at_trx_commit"

    value = "1"

  }

  parameter {

    name = "slow_query_log"

    value = "1"

  }

  parameter {

    name = "long_query_time"

    value = "2"

  }

  parameter {

    name = "general_log"

    value = "1"

  }

  ###################################################
  # Tags
  ###################################################

  tags = {

    Name = "mysql-parameter-group"

  }

}
5. Option Group
resource "aws_db_option_group" "mysql_option" {

  ###################################################
  # General
  ###################################################

  name                     = "mysql-option-group"     # ✅ Required

  engine_name              = "mysql"                  # ✅ Required

  major_engine_version     = "8.0"                    # ✅ Required

  ###################################################
  # Example Option
  ###################################################

  option {

    option_name = "MARIADB_AUDIT_PLUGIN"

  }                                                   # 🔹 Optional

  ###################################################
  # Tags
  ###################################################

  tags = {

    Name = "mysql-option-group"

  }

}
6. KMS Key
resource "aws_kms_key" "rds_key" {

  ###################################################
  # General
  ###################################################

  description = "KMS Key for RDS"             # 🔹 Optional

  deletion_window_in_days = 10                # 🔹 Optional

  enable_key_rotation = true                  # ⭐ Recommended

  is_enabled = true                           # ⭐ Recommended

  ###################################################
  # Tags
  ###################################################

  tags = {

    Name = "rds-kms-key"

  }

}
7. IAM Role (Enhanced Monitoring)
resource "aws_iam_role" "rds_monitoring" {

  ###################################################
  # General
  ###################################################

  name = "rds-monitoring-role"                 # ✅ Required

  ###################################################
  # Trust Policy
  ###################################################

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "monitoring.rds.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

}
8. Read Replica
resource "aws_db_instance" "mysql_read_replica" {

  ###################################################
  # General
  ###################################################

  identifier = "mysql-read-replica"                 # ✅ Required

  replicate_source_db = aws_db_instance.mysql.identifier   # ✅ Required

  instance_class = "db.t4g.micro"                   # ✅ Required

  ###################################################
  # Network
  ###################################################

  publicly_accessible = false                       # ⭐ Recommended

  ###################################################
  # Monitoring
  ###################################################

  auto_minor_version_upgrade = true                 # ⭐ Recommended

  ###################################################
  # Backup
  ###################################################

  skip_final_snapshot = true                        # ⭐ Recommended

  ###################################################
  # Tags
  ###################################################

  tags = {

    Name = "mysql-read-replica"

  }

}
9. Manual Snapshot
resource "aws_db_snapshot" "mysql_snapshot" {

  db_instance_identifier = aws_db_instance.mysql.id     # ✅ Required

  db_snapshot_identifier = "mysql-manual-backup"        # ✅ Required

}
10. Event Subscription
resource "aws_db_event_subscription" "mysql_events" {

  ###################################################
  # General
  ###################################################

  name = "mysql-events"                     # ✅ Required

  sns_topic = aws_sns_topic.rds_events.arn  # ✅ Required

  source_type = "db-instance"               # ✅ Required

  ###################################################
  # Events
  ###################################################

  event_categories = [

    "availability",

    "backup",

    "configuration change",

    "deletion",

    "failover",

    "maintenance",

    "notification"

  ]                                         # 🔹 Optional

}
11. Outputs
output "rds_endpoint" {

  value = aws_db_instance.mysql.endpoint

}

output "rds_port" {

  value = aws_db_instance.mysql.port

}

output "rds_arn" {

  value = aws_db_instance.mysql.arn

}

output "rds_resource_id" {

  value = aws_db_instance.mysql.resource_id

}


1. DB Snapshot Restore ⭐⭐⭐

Restore a database from an existing snapshot.

resource "aws_db_instance" "restore_db" {

  identifier          = "mysql-restored"

  snapshot_identifier = "mysql-manual-backup"

  instance_class      = "db.t4g.micro"

  publicly_accessible = false

}

AWS Console

RDS
   ↓
Snapshots
   ↓
Select Snapshot
   ↓
Restore Snapshot
2. Point-in-Time Restore (PITR) ⭐⭐⭐

Restore the database to a specific time.

resource "aws_db_instance" "point_in_time_restore" {

  identifier = "mysql-pitr"

  restore_to_point_in_time {

    source_db_instance_identifier = aws_db_instance.mysql.identifier

    restore_time = "2026-07-12T05:00:00Z"

  }

}
3. Custom Parameter Group Family

Example:

family = "mysql8.0"

Different engines use different families:

mysql8.0

postgres16

mariadb10.11

oracle-ee

sqlserver-se
4. DB Proxy ⭐⭐⭐⭐

Very important for production.

resource "aws_db_proxy" "mysql_proxy" {

  name = "mysql-proxy"

  engine_family = "MYSQL"

}

AWS Console

RDS

↓

Proxies

↓

Create Proxy

Purpose

Connection pooling
Faster application connectivity
Better scalability
5. Proxy Target Group
resource "aws_db_proxy_default_target_group" "default" {

  db_proxy_name = aws_db_proxy.mysql_proxy.name

}
6. Proxy Target
resource "aws_db_proxy_target" "mysql" {

  db_instance_identifier = aws_db_instance.mysql.identifier

  db_proxy_name = aws_db_proxy.mysql_proxy.name

  target_group_name = "default"

}
7. Custom Endpoint (Aurora only)
aws_rds_cluster_endpoint

Not applicable to standard MySQL RDS.

8. Enhanced Monitoring IAM Policy

You created the IAM Role.

Still missing

resource "aws_iam_role_policy_attachment" "rds_monitoring" {

  role = aws_iam_role.rds_monitoring.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"

}
9. CloudWatch Alarm ⭐⭐⭐⭐

Very common.

resource "aws_cloudwatch_metric_alarm" "cpu" {

  alarm_name = "RDS-CPU"

  metric_name = "CPUUtilization"

}

Useful alarms

CPU
Free Storage
Free Memory
Database Connections
Replica Lag
10. SNS Topic

Required if using Event Subscription.

resource "aws_sns_topic" "rds_events" {

  name = "rds-events"

}
11. SNS Subscription
resource "aws_sns_topic_subscription" "email" {

  topic_arn = aws_sns_topic.rds_events.arn

  protocol = "email"

  endpoint = "admin@example.com"

}
12. CloudWatch Log Group (Optional)
resource "aws_cloudwatch_log_group" "mysql" {

  name = "/aws/rds/mysql"

}
13. Secrets Manager (Production)

Instead of

password = "Admin@123"

Production uses

aws_secretsmanager_secret

aws_secretsmanager_secret_version
14. Random Password
resource "random_password" "db" {

  length = 20

}
