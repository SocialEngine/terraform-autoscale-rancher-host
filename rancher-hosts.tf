# User-data template
# Registers the instance with the rancher server environment
data "template_file" "user_data" {
  template = "${file("${path.module}/files/userdata.template")}"

  vars {
    cluster_name                 = "${var.cluster_name}"
    cluster_instance_labels      = "${var.cluster_instance_labels}"
    rancher_registration_command = "${rancher_registration_token.default.command}"
    server_hostname              = "${var.server_hostname}"
    docker_daemon_options        = "${var.docker_daemon_options}"
  }
}

output "host_user_data" {
  value = "${data.template_file.user_data.rendered}"
}
