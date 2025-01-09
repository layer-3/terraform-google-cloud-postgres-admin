locals {
  users = {
    for user in distinct(flatten(values(var.role_users))) : user => !strcontains(user, "@") ? "builtin" : "iam"
  }
}

resource "google_sql_user" "users" {
  for_each = toset([
    for user, type in local.users : user if type == "iam"
  ])

  instance = var.instance_name
  name     = each.value
  type     = !strcontains(each.key, ".gserviceaccount.com") ? "CLOUD_IAM_USER" : "CLOUD_IAM_SERVICE_ACCOUNT"
}

resource "google_sql_database" "databases" {
  for_each = var.database_schemas

  instance = var.instance_name
  name     = each.key

  depends_on = [
    google_sql_user.users
  ]
}
