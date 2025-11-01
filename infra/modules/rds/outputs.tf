# [Phase 0] /infra/modules/rds/outputs.tf
# Exports the database connection details

output "db_address" {
  description = "The connection endpoint for the RDS instance"
  value       = module.rds.db_instance_address
}

output "db_port" {
  description = "The port the database is listening on"
  value       = module.rds.db_instance_port
}

output "db_username" {
  description = "The database admin username"
  value       = var.db_username
}

output "db_name" {
  description = "The database name"
  value       = module.rds.db_instance_name
}
