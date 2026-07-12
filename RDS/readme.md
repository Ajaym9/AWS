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



