locals {
  roles = merge([
    for database, schemas in var.database_schemas : merge([
      for schema in schemas : {
        for role_type, role_params in var.schema_role_types :
        "${database}_${schema}_${role_type}" => {
          database   = database
          schema     = schema
          users      = var.role_users["${database}_${schema}_${role_type}"]
          privileges = role_params.privileges
        } if lookup(var.role_users, "${database}_${schema}_${role_type}", null) != null
      }
    ]...)
  ]...)
}

resource "postgresql_schema" "schemas" {
  for_each = merge([
    for database, schemas in var.database_schemas : {
      for schema in schemas : schema => database
    }
  ]...)

  database     = each.value
  name         = each.key
  drop_cascade = !var.deletion_protection

  depends_on = [
    google_sql_database.databases,
  ]
}

resource "postgresql_role" "roles" {
  for_each = local.roles

  name = each.key
}

resource "postgresql_grant" "schema_grants" {
  for_each = local.roles

  role     = each.key
  database = each.value.database
  schema   = each.value.schema

  object_type = "schema"
  privileges  = each.value.privileges.schema

  depends_on = [
    postgresql_schema.schemas,
    postgresql_role.roles,
  ]
}

resource "postgresql_grant" "table_grants" {
  for_each = local.roles

  role     = each.key
  database = each.value.database
  schema   = each.value.schema

  object_type = "table"
  privileges  = each.value.privileges.table

  depends_on = [
    postgresql_schema.schemas,
    postgresql_role.roles,
  ]
}

resource "postgresql_grant" "sequence_grants" {
  for_each = local.roles

  role     = each.key
  database = each.value.database
  schema   = each.value.schema

  object_type = "sequence"
  privileges  = each.value.privileges.sequence

  depends_on = [
    postgresql_schema.schemas,
    postgresql_role.roles,
  ]
}

resource "random_password" "builtin_passwords" {
  for_each = toset([
    for user, type in local.users : user if type == "builtin"
  ])

  length = 16
}

resource "postgresql_role" "builtin_users" {
  for_each = toset([
    for user, type in local.users : user if type == "builtin"
  ])

  name     = each.key
  login    = true
  password = random_password.builtin_passwords[each.key].result
}

resource "postgresql_grant_role" "user_role_grants" {
  for_each = merge([
    for role, params in local.roles : {
      for user in params.users : "${role}_${user}" => {
        role = role
        user = user
      }
    }
  ]...)

  role       = each.value.user
  grant_role = each.value.role

  depends_on = [
    postgresql_role.roles,
    postgresql_role.builtin_users,
    google_sql_user.users,
  ]
}
