################################################################################
# RDS DB Instance
# Resource:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
################################################################################

resource "aws_db_instance" "this" {

  ##############################################################################
  # General Configuration
  ##############################################################################

  identifier                     = var.identifier                     # Optional (Required for most new DBs)
  identifier_prefix              = var.identifier_prefix              # Optional
  db_name                        = var.db_name                        # Optional (Not supported for all engines)
  engine                         = var.engine                         # Required
  engine_version                 = var.engine_version                 # Optional
  engine_lifecycle_support       = var.engine_lifecycle_support       # Optional
  instance_class                 = var.instance_class                 # Required
  allocated_storage              = var.allocated_storage              # Optional (Required unless restoring from snapshot)
  storage_type                   = var.storage_type                   # Optional
  storage_throughput             = var.storage_throughput             # Optional (gp3 only)
  iops                           = var.iops                           # Optional (io1/io2/gp3)
  max_allocated_storage          = var.max_allocated_storage          # Optional (Storage Autoscaling)

  ##############################################################################
  # Storage Encryption
  ##############################################################################

  storage_encrypted              = var.storage_encrypted              # Optional
  kms_key_id                     = var.kms_key_id                     # Optional

  ##############################################################################
  # Credentials
  ##############################################################################

  username                       = var.username                       # Optional (Required unless snapshot/replica)
  password                       = var.password                       # Optional (Sensitive)
  manage_master_user_password    = var.manage_master_user_password    # Optional
  master_user_secret_kms_key_id  = var.master_user_secret_kms_key_id  # Optional

  ##############################################################################
  # Port
  ##############################################################################

  port                           = var.port                           # Optional

  ##############################################################################
  # Availability
  ##############################################################################

  availability_zone              = var.availability_zone              # Optional
  multi_az                       = var.multi_az                       # Optional

  ##############################################################################
  # Networking
  ##############################################################################

  publicly_accessible            = var.publicly_accessible            # Optional
  network_type                   = var.network_type                   # Optional (IPV4 | DUAL)
  db_subnet_group_name           = var.db_subnet_group_name           # Optional
  vpc_security_group_ids         = var.vpc_security_group_ids         # Optional

  ##############################################################################
  # Character Sets
  ##############################################################################

  character_set_name             = var.character_set_name             # Optional
  nchar_character_set_name       = var.nchar_character_set_name       # Optional (Oracle)

  ##############################################################################
  # Database Options
  ##############################################################################

  option_group_name              = var.option_group_name              # Optional
  parameter_group_name           = var.parameter_group_name           # Optional

  ##############################################################################
  # License
  ##############################################################################

  license_model                  = var.license_model                  # Optional

  ##############################################################################
  # Time Zone
  ##############################################################################

  timezone                       = var.timezone                       # Optional (SQL Server)

  ##############################################################################
  # CA Certificate
  ##############################################################################

  ca_cert_identifier             = var.ca_cert_identifier             # Optional

  ##############################################################################
  # Processor Features
  ##############################################################################

  dedicated_log_volume           = var.dedicated_log_volume           # Optional

  ##############################################################################
  # Monitoring
  ##############################################################################

  monitoring_interval            = var.monitoring_interval            # Optional
  monitoring_role_arn            = var.monitoring_role_arn            # Optional

  ##############################################################################
  # Performance Insights
  ##############################################################################

  performance_insights_enabled          = var.performance_insights_enabled          # Optional
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id       # Optional
  performance_insights_retention_period = var.performance_insights_retention_period # Optional

  ##############################################################################
  # CloudWatch Logs
  ##############################################################################

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports # Optional

  ##############################################################################
  # IAM Authentication
  ##############################################################################

  iam_database_authentication_enabled = var.iam_database_authentication_enabled # Optional

  ##############################################################################
  # Active Directory
  ##############################################################################

  domain                      = var.domain                      # Optional
  domain_auth_secret_arn      = var.domain_auth_secret_arn      # Optional
  domain_dns_ips              = var.domain_dns_ips              # Optional
  domain_fqdn                 = var.domain_fqdn                 # Optional
  domain_iam_role_name        = var.domain_iam_role_name        # Optional
  domain_ou                   = var.domain_ou                  # Optional

  ##############################################################################
  # Backup Configuration
  ##############################################################################

  backup_retention_period      = var.backup_retention_period      # Optional
  backup_window                = var.backup_window                # Optional
  copy_tags_to_snapshot        = var.copy_tags_to_snapshot        # Optional
  delete_automated_backups     = var.delete_automated_backups     # Optional

  ##############################################################################
  # Maintenance
  ##############################################################################

  maintenance_window           = var.maintenance_window           # Optional
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade   # Optional
  allow_major_version_upgrade  = var.allow_major_version_upgrade  # Optional
  apply_immediately            = var.apply_immediately            # Optional

  ##############################################################################
  # Deletion Protection
  ##############################################################################

  deletion_protection          = var.deletion_protection          # Optional

  ##############################################################################
  # Snapshot Configuration
  ##############################################################################

  skip_final_snapshot          = var.skip_final_snapshot          # Optional
  final_snapshot_identifier    = var.final_snapshot_identifier    # Optional (Required if skip_final_snapshot = false)

  snapshot_identifier          = var.snapshot_identifier          # Optional (Restore from snapshot)

  ##############################################################################
  # Restore From Existing Automated Backup
  ##############################################################################

  restore_to_latest_restorable_time = var.restore_to_latest_restorable_time # Optional
  source_db_instance_identifier     = var.source_db_instance_identifier     # Optional
  source_dbi_resource_id            = var.source_dbi_resource_id            # Optional
  use_latest_restorable_time        = var.use_latest_restorable_time        # Optional

  ##############################################################################
  # Replication
  ##############################################################################

  replicate_source_db         = var.replicate_source_db          # Optional (Read Replica)

  replica_mode                = var.replica_mode                # Optional (Oracle)

  ##############################################################################
  # Blue/Green / Upgrade Related
  ##############################################################################

  upgrade_storage_config      = var.upgrade_storage_config       # Optional

  ##############################################################################
  # Engine Specific
  ##############################################################################

  custom_iam_instance_profile = var.custom_iam_instance_profile  # Optional (RDS Custom)

  ##############################################################################
  # Database Inspection
  ##############################################################################

  database_insights_mode      = var.database_insights_mode       # Optional (Supported engines)

  ##############################################################################
  # Restore To Point In Time
  ##############################################################################

  dynamic "restore_to_point_in_time" {

    for_each = var.restore_to_point_in_time == null ? [] : [var.restore_to_point_in_time]

    content {

      restore_time                             = lookup(restore_to_point_in_time.value, "restore_time", null)

      source_db_instance_automated_backups_arn = lookup(
        restore_to_point_in_time.value,
        "source_db_instance_automated_backups_arn",
        null
      )

      source_db_instance_identifier = lookup(
        restore_to_point_in_time.value,
        "source_db_instance_identifier",
        null
      )

      source_dbi_resource_id = lookup(
        restore_to_point_in_time.value,
        "source_dbi_resource_id",
        null
      )

      use_latest_restorable_time = lookup(
        restore_to_point_in_time.value,
        "use_latest_restorable_time",
        null
      )
    }
  }

  ##############################################################################
  # S3 Import
  ##############################################################################

  dynamic "s3_import" {

    for_each = var.s3_import == null ? [] : [var.s3_import]

    content {

      bucket_name           = lookup(s3_import.value, "bucket_name", null)

      bucket_prefix         = lookup(s3_import.value, "bucket_prefix", null)

      ingestion_role        = lookup(s3_import.value, "ingestion_role", null)

      source_engine         = lookup(s3_import.value, "source_engine", null)

      source_engine_version = lookup(s3_import.value, "source_engine_version", null)

    }
  }

  ##############################################################################
  # Tags
  ##############################################################################

  tags = var.tags

  ##############################################################################
  # Resource Timeouts
  ##############################################################################

  timeouts {

    create = var.create_timeout

    update = var.update_timeout

    delete = var.delete_timeout

  }

  ##############################################################################
  # Lifecycle
  ##############################################################################

  lifecycle {

    ignore_changes = var.ignore_changes

  }

}