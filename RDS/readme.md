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


#########################################################################################
#########################################################################################

Part 1 – aws_db_instance Resource
1. General Configuration

| **Terraform Parameter** | **Requirement** | **What is it?**                                                         | **Purpose / Why is it used?**                                                                              |
| ----------------------- | --------------- | ----------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `identifier`            | ✅ Required      | Unique name of the RDS instance.                                        | AWS uses this identifier to create, identify, and manage the database.                                     |
| `engine`                | ✅ Required      | Database engine like MySQL, PostgreSQL, MariaDB, Oracle, or SQL Server. | Specifies which database software AWS should install.                                                      |
| `engine_version`        | ⭐ Recommended   | Version of the selected database engine.                                | Ensures compatibility and prevents unexpected automatic upgrades.                                          |
| `instance_class`        | ✅ Required      | Size of the database instance (CPU and RAM).                            | Determines the performance, memory, and cost of the RDS instance. Example: `db.t4g.micro`, `db.r6g.large`. |



2. Database Configuration

| **Terraform Parameter**        | **Requirement** |              **What is it?**                 | **Purpose / Why is it used?**                                                                 |
| ----------------------------- | --------------- | --------------------------------------- | --------------------------------------------------------------------------------------------- |
| `db_name`                     | 🔹 Optional     | Name of the initial database.           | Automatically creates a database after the RDS instance is created.                           |
| `username`                    | ✅ Required      | Master database administrator username. | Used to connect to and manage the database.                                                   |
| `password`                    | ✅ Required*     | Password for the master user.           | Secures database access. (*Not required when using AWS Secrets Manager.)                      |
| `manage_master_user_password` | 🔹 Optional     | AWS-managed database password.          | Automatically generates and stores the password in AWS Secrets Manager for improved security. |

3. Storage Configuration


| **Terraform Parameter** | **Requirement** | **What is it?**                              | **Purpose / Why is it used?**                                    |
| ----------------------- | --------------- | -------------------------------------------- | ---------------------------------------------------------------- |
| `allocated_storage`     | ✅ Required      | Initial storage size in GB.                  | Defines how much disk space the database gets during creation.   |
| `storage_type`          | ⭐ Recommended   | Storage type such as `gp3`, `gp2`, or `io2`. | Determines storage performance, IOPS, and pricing.               |
| `max_allocated_storage` | 🔹 Optional     | Maximum storage size allowed.                | Enables storage autoscaling when the database runs out of space. |
| `storage_encrypted`     | ⭐ Recommended   | Enables encryption for database storage.     | Protects data stored on disk using encryption.                   |
| `kms_key_id`            | 🔹 Optional     | AWS KMS key ARN.                             | Specifies the encryption key used to encrypt the database.       |


4. Availability & Durability

| **Terraform Parameter** | **Requirement** | **What is it?**                                          | **Purpose / Why is it used?**                                                    |
| ----------------------- | --------------- | -------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `multi_az`              | ⭐ Recommended   | Deploys a standby database in another Availability Zone. | Provides automatic failover and high availability if the primary instance fails. |
| `availability_zone`     | 🔹 Optional     | AWS Availability Zone where the database is created.     | Used only for Single-AZ deployments to choose a specific AZ.                     |


5. Network Configuration


| **Terraform Parameter**  | **Requirement** | **What is it?**                                           | **Purpose / Why is it used?**                                    |
| ------------------------ | --------------- | --------------------------------------------------------- | ---------------------------------------------------------------- |
| `publicly_accessible`    | ⭐ Recommended   | Determines whether the database gets a public IP address. | Controls whether the database can be accessed from the internet. |
| `network_type`           | 🔹 Optional     | Network protocol used by the database.                    | Specifies IPv4 or Dual Stack (IPv4 + IPv6) networking.           |
| `db_subnet_group_name`   | ⭐ Recommended   | Database subnet group.                                    | Specifies the private subnets where RDS will be deployed.        |
| `vpc_security_group_ids` | ⭐ Recommended   | List of security groups attached to the database.         | Controls inbound and outbound network access to the database.    |



6. Database Groups

| **Terraform Parameter** | **Requirement** | **What is it?**           | **Purpose / Why is it used?**                                                        |
| ----------------------- | --------------- | ------------------------- | ------------------------------------------------------------------------------------ |
| `parameter_group_name`  | 🔹 Optional     | Database parameter group. | Applies custom database configuration settings such as `max_connections` or logging. |
| `option_group_name`     | 🔹 Optional     | Database option group.    | Enables optional database features like audit plugins or advanced functionality.     |


7. Backup Configuration

| **Terraform Parameter**    | **Requirement** | **What is it?**                                         | **Purpose / Why is it used?**                        |
| -------------------------- | --------------- | ------------------------------------------------------- | ---------------------------------------------------- |
| `backup_retention_period`  | ⭐ Recommended   | Number of days to retain automated backups.             | Enables database recovery using automated backups.   |
| `preferred_backup_window`  | 🔹 Optional     | Daily backup schedule.                                  | Specifies when AWS should perform automatic backups. |
| `copy_tags_to_snapshot`    | 🔹 Optional     | Copies resource tags to snapshots.                      | Makes snapshot management and identification easier. |
| `delete_automated_backups` | 🔹 Optional     | Deletes automated backups when the instance is deleted. | Prevents unnecessary backup storage and charges.     |


8. Maintenance

| **Terraform Parameter**        | **Requirement** | **What is it?**                                | **Purpose / Why is it used?**                                  |
| ------------------------------ | --------------- | ---------------------------------------------- | -------------------------------------------------------------- |
| `auto_minor_version_upgrade`   | ⭐ Recommended   | Automatically installs minor database updates. | Keeps the database secure with bug fixes and security patches. |
| `preferred_maintenance_window` | 🔹 Optional     | Weekly maintenance schedule.                   | Specifies when AWS performs maintenance tasks.                 |
| `allow_major_version_upgrade`  | 🔹 Optional     | Allows major version upgrades.                 | Enables upgrades like MySQL 8.0 → 9.0 when supported.          |
| `apply_immediately`            | 🔹 Optional     | Applies configuration changes immediately.     | Avoids waiting for the next maintenance window.                |


9. Monitoring

| **Terraform Parameter**                 | **Requirement** | **What is it?**                                 | **Purpose / Why is it used?**                                                                     |
| --------------------------------------- | --------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `monitoring_interval`                   | 🔹 Optional     | Enhanced Monitoring interval (seconds).         | Sends detailed operating system metrics to CloudWatch.                                            |
| `monitoring_role_arn`                   | 🔹 Optional     | IAM role for Enhanced Monitoring.               | Grants RDS permission to publish monitoring data.                                                 |
| `performance_insights_enabled`          | ⭐ Recommended   | Enables Performance Insights.                   | Helps identify slow SQL queries and performance bottlenecks.                                      |
| `performance_insights_retention_period` | 🔹 Optional     | Retention period for Performance Insights data. | Controls how long performance metrics are stored.                                                 |
| `enabled_cloudwatch_logs_exports`       | 🔹 Optional     | Database logs exported to CloudWatch.           | Makes logs like `error`, `general`, and `slowquery` available for monitoring and troubleshooting. |


10. Authentication

| **Terraform Parameter**               | **Requirement** | **What is it?**             | **Purpose / Why is it used?**                                           |
| ------------------------------------- | --------------- | --------------------------- | ----------------------------------------------------------------------- |
| `iam_database_authentication_enabled` | 🔹 Optional     | Enables IAM authentication. | Allows IAM users and roles to connect without using database passwords. |


11. SSL Configuration

| **Terraform Parameter** | **Requirement** | **What is it?**                  | **Purpose / Why is it used?**                                        |
| ----------------------- | --------------- | -------------------------------- | -------------------------------------------------------------------- |
| `ca_cert_identifier`    | 🔹 Optional     | SSL/TLS certificate used by RDS. | Secures encrypted connections between applications and the database. |


12. Deletion Protection

| **Terraform Parameter**     | **Requirement**     | **What is it?**                                | **Purpose / Why is it used?**                                     |
| --------------------------- | ------------------- | ---------------------------------------------- | ----------------------------------------------------------------- |
| `deletion_protection`       | ⭐ Recommended       | Prevents accidental database deletion.         | Protects production databases from being deleted unintentionally. |
| `skip_final_snapshot`       | ⭐ Recommended (Lab) | Skips creating a final backup before deletion. | Speeds up deletion in development or lab environments.            |
| `final_snapshot_identifier` | 🔹 Optional         | Name of the final snapshot.                    | Creates a backup before deleting the production database.         |


13. Character Set

| **Terraform Parameter** | **Requirement** | **What is it?**                              | **Purpose / Why is it used?**                                                           |
| ----------------------- | --------------- | -------------------------------------------- | --------------------------------------------------------------------------------------- |
| `character_set_name`    | 🔹 Optional     | Default character encoding for the database. | Ensures correct storage of multilingual characters and emojis (for example, `utf8mb4`). |


14. License Configuration

| **Terraform Parameter** | **Requirement** | **What is it?**           | **Purpose / Why is it used?**                                                     |
| ----------------------- | --------------- | ------------------------- | --------------------------------------------------------------------------------- |
| `license_model`         | 🔹 Optional     | Software licensing model. | Specifies the database license type, mainly used for commercial database engines. |


15. Port Configuration

| **Terraform Parameter** | **Requirement** | **What is it?**                    | **Purpose / Why is it used?**                                                         |
| ----------------------- | --------------- | ---------------------------------- | ------------------------------------------------------------------------------------- |
| `port`                  | 🔹 Optional     | Network port used by the database. | Defines the port applications use to connect (e.g., MySQL `3306`, PostgreSQL `5432`). |


16. Tags

| **Terraform Parameter** | **Requirement** | **What is it?**                            | **Purpose / Why is it used?**                                                                              |
| ----------------------- | --------------- | ------------------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| `tags`                  | 🔹 Optional     | Key-value labels assigned to the resource. | Helps organize, search, automate, and manage AWS resources by environment, project, owner, or cost center. |


Part 2 – Supporting Resources
1. DB Subnet Group (aws_db_subnet_group)

A DB Subnet Group tells AWS which subnets RDS is allowed to use. For production, it should contain at least two private subnets in different Availability Zones.


| **Terraform Parameter** | **Requirement** | **What is it?**                  | **Purpose / Why is it used?**                                                  |
| ----------------------- | --------------- | -------------------------------- | ------------------------------------------------------------------------------ |
| `name`                  | ✅ Required      | Name of the DB subnet group.     | AWS uses this name to identify and attach the subnet group to an RDS instance. |
| `description`           | 🔹 Optional     | Description of the subnet group. | Helps administrators understand the purpose of the subnet group.               |


Subnet Configuration

| **Terraform Parameter** | **Requirement** | **What is it?**         | **Purpose / Why is it used?**                                                                                                                    |
| ----------------------- | --------------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `subnet_ids`            | ✅ Required      | List of VPC subnet IDs. | Specifies where AWS can deploy the RDS instance. Production requires at least two subnets in different Availability Zones for high availability. |


Tags

| **Terraform Parameter** | **Requirement** | **What is it?**                        | **Purpose / Why is it used?**                               |
| ----------------------- | --------------- | -------------------------------------- | ----------------------------------------------------------- |
| `tags`                  | 🔹 Optional     | Key-value labels for the subnet group. | Helps organize resources by project, owner, or environment. |


2. Security Group (aws_security_group)

A Security Group acts as a virtual firewall that controls who can connect to your RDS database.

General Configuration

| **Terraform Parameter** | **Requirement** | **What is it?**                    | **Purpose / Why is it used?**                      |
| ----------------------- | --------------- | ---------------------------------- | -------------------------------------------------- |
| `name`                  | ✅ Required      | Name of the security group.        | Identifies the security group inside the VPC.      |
| `description`           | 🔹 Optional     | Description of the security group. | Explains why this security group exists.           |
| `vpc_id`                | ✅ Required      | ID of the VPC.                     | Associates the security group with a specific VPC. |


Inbound Rule (ingress)

| **Terraform Parameter** | **Requirement** | **What is it?**                           | **Purpose / Why is it used?**                                                                                       |
| ----------------------- | --------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `description`           | 🔹 Optional     | Description of the inbound rule.          | Helps identify what the rule allows.                                                                                |
| `from_port`             | ✅ Required      | Starting port number.                     | Defines the beginning of the allowed port range.                                                                    |
| `to_port`               | ✅ Required      | Ending port number.                       | Defines the end of the allowed port range.                                                                          |
| `protocol`              | ✅ Required      | Network protocol (TCP, UDP, ICMP).        | Specifies the communication protocol allowed.                                                                       |
| `security_groups`       | ⭐ Recommended   | Source security group allowed to connect. | Allows only trusted resources (such as EC2 instances) to access the database instead of opening access to everyone. |
| `cidr_blocks`           | 🔹 Optional     | Allowed IP address ranges.                | Used when allowing access from specific public or private IP addresses.                                             |


Outbound Rule (egress)

| **Terraform Parameter** | **Requirement** | **What is it?**                  | **Purpose / Why is it used?**                     |
| ----------------------- | --------------- | -------------------------------- | ------------------------------------------------- |
| `from_port`             | ✅ Required      | Starting outbound port.          | Defines the outbound port range.                  |
| `to_port`               | ✅ Required      | Ending outbound port.            | Defines the outbound port range.                  |
| `protocol`              | ✅ Required      | Outbound communication protocol. | Specifies which protocol is allowed.              |
| `cidr_blocks`           | 🔹 Optional     | Destination IP range.            | Controls where outbound traffic is allowed to go. |


Tags

| **Terraform Parameter** | **Requirement** | **What is it?**  | **Purpose / Why is it used?**                   |
| ----------------------- | --------------- | ---------------- | ----------------------------------------------- |
| `tags`                  | 🔹 Optional     | Resource labels. | Helps organize and identify the security group. |


3. DB Parameter Group (aws_db_parameter_group)

A Parameter Group contains database configuration settings that control how the database behaves.

General Configuration

| **Terraform Parameter** | **Requirement** | **What is it?**              | **Purpose / Why is it used?**                                                   |
| ----------------------- | --------------- | ---------------------------- | ------------------------------------------------------------------------------- |
| `name`                  | ✅ Required      | Name of the parameter group. | AWS uses it to identify the custom parameter group.                             |
| `family`                | ✅ Required      | Database engine family.      | Must match the database engine version (for example, `mysql8.0`, `postgres16`). |


Parameter Block

| **Terraform Parameter** | **Requirement** | **What is it?**                  | **Purpose / Why is it used?**                         |
| ----------------------- | --------------- | -------------------------------- | ----------------------------------------------------- |
| `parameter`             | 🔹 Optional     | Collection of database settings. | Used to customize database behavior.                  |
| `name`                  | ✅ Required      | Database parameter name.         | Specifies which database setting you want to change.  |
| `value`                 | ✅ Required      | Value assigned to the parameter. | Defines the new configuration value for that setting. |



Common Parameters

| **Parameter Name**               | **What is it?**                  | **Purpose / Why is it used?**                         |
| -------------------------------- | -------------------------------- | ----------------------------------------------------- |
| `max_connections`                | Maximum client connections.      | Controls how many users can connect at the same time. |
| `binlog_format`                  | Binary log format.               | Required for replication and recovery.                |
| `innodb_flush_log_at_trx_commit` | Transaction log flushing method. | Controls data durability and performance.             |
| `slow_query_log`                 | Enables slow query logging.      | Helps identify slow-running SQL queries.              |
| `long_query_time`                | Slow query threshold (seconds).  | Queries longer than this value are logged.            |
| `general_log`                    | Enables general query logging.   | Records every SQL query for troubleshooting.          |


Tags

| **Terraform Parameter** | **Requirement** | **What is it?**  | **Purpose / Why is it used?**    |
| ----------------------- | --------------- | ---------------- | -------------------------------- |
| `tags`                  | 🔹 Optional     | Resource labels. | Helps organize parameter groups. |


4. DB Option Group (aws_db_option_group)

An Option Group enables optional database features that are not enabled by default.

General Configuration

| **Terraform Parameter** | **Requirement** | **What is it?**           | **Purpose / Why is it used?**                               |
| ----------------------- | --------------- | ------------------------- | ----------------------------------------------------------- |
| `name`                  | ✅ Required      | Name of the option group. | AWS uses this name to identify the option group.            |
| `engine_name`           | ✅ Required      | Database engine.          | Specifies which database engine this option group supports. |
| `major_engine_version`  | ✅ Required      | Database major version.   | Ensures compatibility with the selected database version.   |


Option Block

| **Terraform Parameter** | **Requirement** | **What is it?**                      | **Purpose / Why is it used?**                                                 |
| ----------------------- | --------------- | ------------------------------------ | ----------------------------------------------------------------------------- |
| `option_name`           | 🔹 Optional     | Optional database feature or plugin. | Enables advanced database functionality such as auditing or security plugins. |


Tags

| **Terraform Parameter** | **Requirement** | **What is it?**  | **Purpose / Why is it used?** |
| ----------------------- | --------------- | ---------------- | ----------------------------- |
| `tags`                  | 🔹 Optional     | Resource labels. | Helps organize option groups. |



5. AWS KMS Key (aws_kms_key)

A KMS Key encrypts sensitive data such as RDS storage, snapshots, and backups.

General Configuration

| **Terraform Parameter**   | **Requirement** | **What is it?**                                      | **Purpose / Why is it used?**                                         |
| ------------------------- | --------------- | ---------------------------------------------------- | --------------------------------------------------------------------- |
| `description`             | 🔹 Optional     | Description of the KMS key.                          | Helps identify the encryption key.                                    |
| `deletion_window_in_days` | 🔹 Optional     | Waiting period before deleting the key.              | Prevents accidental permanent deletion.                               |
| `enable_key_rotation`     | ⭐ Recommended   | Automatically rotates the encryption key every year. | Improves security by periodically changing the encryption key.        |
| `is_enabled`              | ⭐ Recommended   | Enables or disables the key.                         | Determines whether the key can be used for encryption and decryption. |


Tags

| **Terraform Parameter** | **Requirement** | **What is it?**  | **Purpose / Why is it used?**   |
| ----------------------- | --------------- | ---------------- | ------------------------------- |
| `tags`                  | 🔹 Optional     | Resource labels. | Helps organize encryption keys. |


6. IAM Role (aws_iam_role) – Enhanced Monitoring

An IAM Role allows Amazon RDS to access other AWS services such as CloudWatch for Enhanced Monitoring.

General Configuration

| **Terraform Parameter** | **Requirement** | **What is it?**       | **Purpose / Why is it used?**                          |
| ----------------------- | --------------- | --------------------- | ------------------------------------------------------ |
| `name`                  | ✅ Required      | Name of the IAM role. | AWS uses this role to identify and manage permissions. |



Trust Policy

| **Terraform Parameter** | **Requirement** | **What is it?**                            | **Purpose / Why is it used?**                                                                                                     |
| ----------------------- | --------------- | ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| `assume_role_policy`    | ✅ Required      | JSON policy defining trusted AWS services. | Allows Amazon RDS (`monitoring.rds.amazonaws.com`) to assume this IAM role and publish Enhanced Monitoring metrics to CloudWatch. |


Part 3 – Production & Advanced RDS Resources

These resources are commonly used in production environments for high availability, backups, monitoring, security, and scalability.

1. Read Replica (aws_db_instance)

A Read Replica is a read-only copy of the primary database. It improves application performance by handling read requests separately.

General Configuration

| **Terraform Parameter** | **Requirement** | **What is it?**                     | **Purpose / Why is it used?**                                      |
| ----------------------- | --------------- | ----------------------------------- | ------------------------------------------------------------------ |
| `identifier`            | ✅ Required      | Name of the read replica.           | AWS uses this unique name to create and manage the replica.        |
| `replicate_source_db`   | ✅ Required      | Primary database to replicate.      | Copies data continuously from the primary database to the replica. |
| `instance_class`        | ✅ Required      | CPU and memory size of the replica. | Determines the performance and cost of the read replica.           |


Network Configuration

| **Terraform Parameter** | **Requirement** | **What is it?**                      | **Purpose / Why is it used?**                  |
| ----------------------- | --------------- | ------------------------------------ | ---------------------------------------------- |
| `publicly_accessible`   | ⭐ Recommended   | Public accessibility of the replica. | Keeps the replica private for better security. |


Maintenance

| **Terraform Parameter**      | **Requirement** | **What is it?**          | **Purpose / Why is it used?**                        |
| ---------------------------- | --------------- | ------------------------ | ---------------------------------------------------- |
| `auto_minor_version_upgrade` | ⭐ Recommended   | Automatic minor updates. | Keeps the replica secure with bug fixes and patches. |


Backup

| **Terraform Parameter** | **Requirement**     | **What is it?**                    | **Purpose / Why is it used?**                   |
| ----------------------- | ------------------- | ---------------------------------- | ----------------------------------------------- |
| `skip_final_snapshot`   | ⭐ Recommended (Lab) | Skip final backup during deletion. | Speeds up deletion in development environments. |


Tags

| **Terraform Parameter** | **Requirement** | **What is it?**  | **Purpose / Why is it used?**                         |
| ----------------------- | --------------- | ---------------- | ----------------------------------------------------- |
| `tags`                  | 🔹 Optional     | Resource labels. | Helps organize the replica by project or environment. |


2. Manual Snapshot (aws_db_snapshot)

A Manual Snapshot is a user-created backup that remains until you delete it

| **Terraform Parameter**  | **Requirement** | **What is it?**       | **Purpose / Why is it used?**                                   |
| ------------------------ | --------------- | --------------------- | --------------------------------------------------------------- |
| `db_instance_identifier` | ✅ Required      | Database to back up.  | Specifies which RDS instance AWS should create a snapshot from. |
| `db_snapshot_identifier` | ✅ Required      | Name of the snapshot. | Uniquely identifies the manual snapshot.                        |


3. Event Subscription (aws_db_event_subscription)

Receives notifications whenever important database events occur.

General Configuration

| **Terraform Parameter** | **Requirement** | **What is it?**                 | **Purpose / Why is it used?**                                              |
| ----------------------- | --------------- | ------------------------------- | -------------------------------------------------------------------------- |
| `name`                  | ✅ Required      | Name of the event subscription. | Identifies the subscription in AWS.                                        |
| `sns_topic`             | ✅ Required      | SNS Topic ARN.                  | Sends notifications to email, SMS, Lambda, etc.                            |
| `source_type`           | ✅ Required      | Resource type to monitor.       | Specifies whether events come from DB instances, snapshots, clusters, etc. |


Event Categories

| **Terraform Parameter** | **Requirement** | **What is it?**             | **Purpose / Why is it used?**                                                                         |
| ----------------------- | --------------- | --------------------------- | ----------------------------------------------------------------------------------------------------- |
| `event_categories`      | 🔹 Optional     | Types of events to monitor. | Receives alerts only for selected database events such as backup, failover, maintenance, or deletion. |


4. Outputs

Outputs display important information after Terraform finishes creating resources.

| **Terraform Output** | **What is it?**             | **Purpose / Why is it used?**                                                 |
| -------------------- | --------------------------- | ----------------------------------------------------------------------------- |
| `rds_endpoint`       | Database endpoint.          | Used by applications to connect to the database.                              |
| `rds_port`           | Database port number.       | Used along with the endpoint for connectivity.                                |
| `rds_arn`            | Amazon Resource Name (ARN). | Used for IAM policies, automation, and integrations.                          |
| `rds_resource_id`    | AWS internal resource ID.   | Used by AWS services and scripts that require the unique resource identifier. |


5. Snapshot Restore

Creates a new database from an existing snapshot.

| **Terraform Parameter** | **Requirement** | **What is it?**                | **Purpose / Why is it used?**                             |
| ----------------------- | --------------- | ------------------------------ | --------------------------------------------------------- |
| `snapshot_identifier`   | ✅ Required      | Existing snapshot name.        | Restores a new database from a previously created backup. |
| `identifier`            | ✅ Required      | Name of the restored database. | Gives a unique name to the restored RDS instance.         |
| `instance_class`        | ✅ Required      | Database server size.          | Defines the CPU and memory of the restored database.      |
| `publicly_accessible`   | ⭐ Recommended   | Public accessibility.          | Keeps the restored database private.                      |


6. Point-in-Time Restore (PITR)

Restores the database to a specific date and time.

| **Terraform Parameter**         | **Requirement** | **What is it?**                | **Purpose / Why is it used?**                               |
| ------------------------------- | --------------- | ------------------------------ | ----------------------------------------------------------- |
| `source_db_instance_identifier` | ✅ Required      | Source database.               | Database that AWS restores from.                            |
| `restore_time`                  | ✅ Required      | Date and time.                 | Restores the database to an exact point before data loss.   |
| `identifier`                    | ✅ Required      | Name of the restored database. | Creates a new RDS instance from the selected restore point. |


7. DB Proxy (aws_db_proxy)

A DB Proxy manages database connections between applications and RDS.

| **Terraform Parameter** | **Requirement** | **What is it?**         | **Purpose / Why is it used?**                                |
| ----------------------- | --------------- | ----------------------- | ------------------------------------------------------------ |
| `name`                  | ✅ Required      | Name of the proxy.      | AWS uses it to identify the DB Proxy.                        |
| `engine_family`         | ✅ Required      | Database engine family. | Specifies whether the proxy supports MySQL, PostgreSQL, etc. |

Why DB Proxy?

| **Feature**        | **Purpose**                                                                   |
| ------------------ | ----------------------------------------------------------------------------- |
| Connection Pooling | Reuses existing database connections instead of creating new ones repeatedly. |
| Better Performance | Reduces database connection overhead.                                         |
| High Scalability   | Supports thousands of application connections efficiently.                    |
| Faster Failover    | Quickly reconnects applications during database failover.                     |


8. Proxy Target Group (aws_db_proxy_default_target_group)

| **Terraform Parameter** | **Requirement** | **What is it?** | **Purpose / Why is it used?**                          |
| ----------------------- | --------------- | --------------- | ------------------------------------------------------ |
| `db_proxy_name`         | ✅ Required      | Proxy name.     | Associates the default target group with the DB Proxy. |


9. Proxy Target (aws_db_proxy_target)

| **Terraform Parameter**  | **Requirement** | **What is it?**     | **Purpose / Why is it used?**                          |
| ------------------------ | --------------- | ------------------- | ------------------------------------------------------ |
| `db_instance_identifier` | ✅ Required      | Database instance.  | Registers the RDS instance with the DB Proxy.          |
| `db_proxy_name`          | ✅ Required      | Proxy name.         | Specifies which proxy the database belongs to.         |
| `target_group_name`      | ✅ Required      | Proxy target group. | Associates the database with the proxy's target group. |


10. IAM Role Policy Attachment

| **Terraform Parameter** | **Requirement** | **What is it?**         | **Purpose / Why is it used?**                  |
| ----------------------- | --------------- | ----------------------- | ---------------------------------------------- |
| `role`                  | ✅ Required      | IAM Role name.          | Specifies the role receiving the policy.       |
| `policy_arn`            | ✅ Required      | AWS managed policy ARN. | Grants Enhanced Monitoring permissions to RDS. |


11. CloudWatch Alarm (aws_cloudwatch_metric_alarm)

Monitors important database metrics.

| **Terraform Parameter** | **Requirement** | **What is it?**        | **Purpose / Why is it used?**                       |
| ----------------------- | --------------- | ---------------------- | --------------------------------------------------- |
| `alarm_name`            | ✅ Required      | Alarm name.            | Identifies the CloudWatch alarm.                    |
| `metric_name`           | ✅ Required      | AWS metric to monitor. | Specifies which database metric CloudWatch watches. |


Common RDS Metrics
Metric	Purpose
CPUUtilization	Detects high CPU usage.
FreeStorageSpace	Alerts when storage becomes low.
FreeableMemory	Detects memory shortages.
DatabaseConnections	Monitors active database connections.
ReplicaLag	Monitors delay between primary and replica databases.


12. SNS Topic (aws_sns_topic)

| **Terraform Parameter** | **Requirement** | **What is it?** | **Purpose / Why is it used?**                          |
| ----------------------- | --------------- | --------------- | ------------------------------------------------------ |
| `name`                  | ✅ Required      | SNS Topic name. | Acts as a central notification channel for RDS alerts. |


13. SNS Subscription (aws_sns_topic_subscription)

| **Terraform Parameter** | **Requirement** | **What is it?**      | **Purpose / Why is it used?**                                                     |
| ----------------------- | --------------- | -------------------- | --------------------------------------------------------------------------------- |
| `topic_arn`             | ✅ Required      | SNS Topic ARN.       | Connects the subscription to the SNS topic.                                       |
| `protocol`              | ✅ Required      | Notification method. | Defines how notifications are delivered (email, SMS, Lambda, HTTPS, etc.).        |
| `endpoint`              | ✅ Required      | Recipient address.   | Specifies where notifications are sent, such as an email address or phone number. |


14. CloudWatch Log Group (aws_cloudwatch_log_group)

| **Terraform Parameter** | **Requirement** | **What is it?**            | **Purpose / Why is it used?**                                           |
| ----------------------- | --------------- | -------------------------- | ----------------------------------------------------------------------- |
| `name`                  | ✅ Required      | CloudWatch Log Group name. | Stores exported RDS logs for monitoring, troubleshooting, and auditing. |


15. AWS Secrets Manager

Stores database passwords securely instead of hardcoding them.

| **Resource**                        | **What is it?**   | **Purpose / Why is it used?**                             |
| ----------------------------------- | ----------------- | --------------------------------------------------------- |
| `aws_secretsmanager_secret`         | Secret container. | Securely stores sensitive credentials.                    |
| `aws_secretsmanager_secret_version` | Secret value.     | Stores the actual username/password or connection string. |


16. Random Password (random_password)

Automatically generates a strong password.

| **Terraform Parameter** | **Requirement** | **What is it?**  | **Purpose / Why is it used?**                                        |
| ----------------------- | --------------- | ---------------- | -------------------------------------------------------------------- |
| `length`                | ✅ Required      | Password length. | Specifies how many characters the generated password should contain. |


Production Architecture Summary

| **Resource**       | **Primary Purpose**                |
| ------------------ | ---------------------------------- |
| Read Replica       | Scale read operations              |
| Manual Snapshot    | Permanent backup                   |
| PITR               | Restore to a specific time         |
| DB Proxy           | Connection pooling and scalability |
| CloudWatch Alarm   | Monitor database health            |
| SNS                | Send notifications                 |
| Event Subscription | Receive RDS event alerts           |
| Secrets Manager    | Secure credential management       |
| KMS Key            | Encrypt storage and backups        |
| Parameter Group    | Customize database settings        |
| Option Group       | Enable database features           |
| IAM Role           | Enhanced Monitoring permissions    |


