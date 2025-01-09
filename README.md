# Terraform Module for Google Cloud Postgres Administration

This module configures a Google Cloud SQL Postgres with databases, schemas, roles and users.

## Example

The following example creates a simple Google Cloud SQL Postgres 12 instance with 2 CPUs and 4GB of RAM.
```hcl
module "cloud_postgresql_admin" {
  source = "layer-3/cloud-postgres-admin/google"
  version = "1.0.0"

  project_id = "my-project"
  instance_name = "my-postgres"
  
  instance_host     = "localhost"
  instance_port     = 5432
  instance_user     = "postgres"
  instance_password = "password"
  
  database_schemas = {
    "finance" = [
      "user",
      "admin",
    ]
  }
  
  role_users = {
    "finance_user_reader" = ["user@example.com"]
    "finance_user_admin"  = ["admin@example.com"]
    "finance_admin_admin"   = ["admin@example.com"]
  }
}
```

## Author

This module is maintained by [philanton](https://github.com/philanton).

## License

This module is licensed under the MIT License.
