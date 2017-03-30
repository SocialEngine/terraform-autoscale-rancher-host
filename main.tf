terraform {
  required_version = ">= 0.9.0"
}

# Rancher server details
variable "server_security_group_id" {
  description = "Security group id of the Rancher server so we can restrict incoming traffic."
}

variable "server_hostname" {
  description = "Hostname of the Rancher server."
}

# Target server environment
variable "environment_id" {
  description = "Target environment id for host registration."
}

variable "environment_access_key" {
  description = "API access key for target environment"
}

variable "environment_secret_key" {
  description = "API secret key for target environment"
}

# Cluster setup
variable "cluster_name" {
  description = "The name of the cluster. Best not to include non-alphanumeric characters. Will be used to name resources and tag instances."
}

variable "cluster_autoscaling_group_name" {
  description = "Name of the target autoscaling group."
}

variable "cluster_instance_labels" {
  description = "Additional labels to attach to host instances. Should be in the format: key=value&key2=value2"
  default     = ""
}

# Docker options
variable "docker_daemon_options" {
  description = "Docker daemon options to write to the docker config file before startup."
  default     = ""
}
