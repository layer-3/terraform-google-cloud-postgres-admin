variable "project_id" {
  type        = string
  description = "The project ID to deploy into"
  nullable    = false
}

variable "instance_name" {
  type        = string
  description = "The name of the PostgreSQL instance"
  nullable    = false
}

variable "instance_host" {
  type        = string
  description = "The host of the PostgreSQL instance"
  nullable    = false
}

variable "instance_port" {
  type        = number
  description = "The port of the PostgreSQL instance"
  default     = 5432
}

variable "instance_user" {
  type        = string
  description = "The user to connect to the PostgreSQL instance"
  default     = "postgres"
}

variable "instance_password" {
  type        = string
  description = "The password to connect to the PostgreSQL instance"
  sensitive   = true
  nullable    = false
}

variable "deletion_protection" {
  type        = bool
  description = "Whether to enable deletion protection for the schemas' objects"
  default     = true
}

variable "schema_role_types" {
  type = map(object({
    privileges = object({
      schema   = list(string)
      table    = list(string)
      sequence = list(string)
    })
  }))
  description = "Roles that can be assigned to schema objects"
  default = {
    "admin" = {
      privileges = {
        schema   = ["USAGE", "CREATE"],
        table    = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "TRIGGER"],
        sequence = ["USAGE", "SELECT", "UPDATE"]
      }
    }
    "reader" = {
      privileges = {
        schema   = ["USAGE"],
        table    = ["SELECT"],
        sequence = ["USAGE", "SELECT"]
      }
    }
  }
}

variable "database_schemas" {
  type        = map(list(string))
  description = "Names of schemas to create in databases"
  default     = {}
}

# database -> schema -> role <- user
variable "role_users" {
  type        = map(list(string))
  description = "Users RBAC (key: <database>_<schema>_<role_type>, value: users)"
  default     = {}
}
