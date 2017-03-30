# Configure the Rancher provider
provider "rancher" {
  api_url    = "${var.server_hostname}"
  access_key = "${var.environment_access_key}"
  secret_key = "${var.environment_secret_key}"
}

# Create a new Rancher registration token
resource "rancher_registration_token" "default" {
  name           = "registration_token"
  description    = "Registration token for hosts in provided environment"
  environment_id = "${var.environment_id}"
}
