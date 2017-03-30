# Rancher Hosts AutoScale Cluster

Rancher Hosts AutoScale terraform module is a reusable way
to create autoscale backed Amazon Linux rancher hosts that
automatically register and label themselves upon boot.

## Features

* Flexible (bring your own SG, autoscale group, launch config)
* Low footprint (doesn't create security groups, SQS queue, etc)
* Plays nicely with Private Subnet hosts
* Works with [storage](https://github.com/rancher/storage) plugins
* Uses built-in [rancher](https://www.terraform.io/docs/providers/rancher/index.html) provider

## Requirements

- Terraform 0.9.x
- Auto Scaling Group and Launch Configuration
- functional Security Group
- Rancher server API keys and an environment

## Usage

```hcl
module "cluster" {
  # Import the module from Github
  source = "github.com/SocialEngine/terraform-autoscale-rancher-host?ref=v1.0.1"


  # Name your cluster and provide the auto-scaling group name and security group id.
  # See examples below.
  cluster_name = "rancher-cluster"

  # Add Rancher server details, sg group is redundant
  server_security_group_id = "${data.aws_security_group.private.id}"
  server_hostname          = "${var.rancher_api_url}"

  # Rancher environment
  # In your Rancher server, create an environment and an API keypair. You can have
  # multiple host clusters per environment if necessary. Instances will be labelled
  # with the cluster name so you can differentiate between multiple clusters.
  environment_id = "${var.rancher_env_id}"

  environment_access_key = "${var.rancher_access_key}"
  environment_secret_key = "${var.rancher_access_secret}"

  # Additional labels can be supplied here
  cluster_instance_labels = "type=node"

  cluster_autoscaling_group_name = "${aws_autoscaling_group.cluster_autoscale_group.name}"
}
```

Run `terraform get` to download the module locally. Also check 
[releases](https://github.com/SocialEngine/terraform-autoscale-rancher-host/releases) for latest version.

Each launched host will show up in rancher with these labels:

- `awsaz`: Availability zone for the host
- `cluster`: `${cluster_name}` above
- `hostid`: instance id, i.e `i-123abc`

Additionally, we set each hostname to be `${cluster_name}-${hostId}`

## Examples of required resources

### Security Group

```hcl
data "aws_security_group" "private" {
  id = "${var.security_group_id}"
}
```

### AutoScaling

```hcl
# Autoscaling launch configuration
resource "aws_launch_configuration" "cluster_launch_conf" {
  # Use prefix so configuration can be recreated
  name_prefix = "rancher-node-config-"

  # Amazon linux, us-west-2
  image_id = "ami-165a0876"

  # No public ip when instances are placed in private subnets. See notes
  # about creating an ELB to proxy public traffic into the cluster.
  associate_public_ip_address = false

  # Security groups
  security_groups = [
    "${var.security_group_id}",
  ]

  # Key
  # NOTE: It's a good idea to use the same key as the Rancher server here.
  key_name = "${var.server_private_key_name}"

  # Add rendered userdata template
  user_data = "${module.cluster.host_user_data}"

  # Misc
  instance_type     = "t2.small"
  enable_monitoring = true

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaling group
resource "aws_autoscaling_group" "cluster_autoscale_group" {
  name                      = "rancher-ASG"
  launch_configuration      = "${aws_launch_configuration.cluster_launch_conf.name}"
  min_size                  = "2"
  max_size                  = "5"
  desired_capacity          = "2"
  health_check_grace_period = 180
  health_check_type         = "EC2"
  force_delete              = false
  termination_policies      = ["OldestInstance"]

  # Target subnets
  vpc_zone_identifier = ["${var.private_subnets}"]
  availability_zones  = ["${var.availability_zones}"]

  tag {
    key                 = "Name"
    value               = "rancher-asg-node"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
```

## Attribution and License 

This is based heavily on [`terraform-aws-rancher-hosts`](https://github.com/greensheep/terraform-aws-rancher-hosts) by @greensheep. Thank you for your work.

Similarly, licensed under MIT. See `LICENSE` file for full details.