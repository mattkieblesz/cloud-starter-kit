variable "name"              { }
variable "key_name"          { }
variable "artifact_type"     { }
variable "region"            { }
variable "sub_domain"        { }
variable "site_public_key"   { }
variable "site_private_key"  { }
variable "site_ssl_cert"     { }
variable "site_ssl_key"      { }

variable "vpc_cidr"        { }
variable "azs"             { }
variable "private_subnets" { }
variable "public_subnets"  { }

variable "bastion_instance_type" { }

variable "openvpn_instance_type" { }
variable "openvpn_ami"           { }
variable "openvpn_user"          { }
variable "openvpn_admin_user"    { }
variable "openvpn_admin_pw"      { }
variable "openvpn_cidr"          { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.key_name}"
  public_key = "${var.site_public_key}"

  lifecycle { create_before_destroy = true }
}

module "foundation" {
  source = "foundation"

  name            = "${var.name}"
  vpc_cidr        = "${var.vpc_cidr}"
  azs             = "${var.azs}"
  region          = "${var.region}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"
  ssl_cert        = "${var.site_ssl_cert}"
  ssl_key         = "${var.site_ssl_key}"
  key_name        = "${aws_key_pair.site_key.key_name}"
  private_key     = "${var.site_private_key}"
  sub_domain      = "${var.sub_domain}"
  route_zone_id   = "${terraform_remote_state.aws_global.output.zone_id}"

  bastion_instance_type = "${var.bastion_instance_type}"
  openvpn_instance_type = "${var.openvpn_instance_type}"
  openvpn_ami           = "${var.openvpn_ami}"
  openvpn_user          = "${var.openvpn_user}"
  openvpn_admin_user    = "${var.openvpn_admin_user}"
  openvpn_admin_pw      = "${var.openvpn_admin_pw}"
  openvpn_cidr          = "${var.openvpn_cidr}"
}

output "iam_admin_users"       { value = "${module.iam_admin.users}" }
output "iam_admin_access_ids"  { value = "${module.iam_admin.access_ids}" }
output "iam_admin_secret_keys" { value = "${module.iam_admin.secret_keys}" }

output "zone_id" { value = "${aws_route53_zone.zone.zone_id}" }

output "configuration" {
  value = <<CONFIGURATION

DNS records have been set in Route53, add NS records for ${var.domain} pointing to:
  ${join("\n  ", formatlist("%s", aws_route53_zone.zone.*.name_servers))}
Admin IAM:
  Admin Users: ${join("\n               ", formatlist("%s", split(",", module.iam_admin.users)))}
  Access IDs: ${join("\n              ", formatlist("%s", split(",", module.iam_admin.access_ids)))}
  Secret Keys: ${join("\n               ", formatlist("%s", split(",", module.iam_admin.secret_keys)))}

Add your private key and SSH into any private node via the Bastion host:
  ssh-add ../../../modules/keys/demo.pem
  ssh -A ${module.foundation.bastion_user}@${module.foundation.bastion_public_ip}

The VPC environment is accessible via an OpenVPN connection:
  Server:   ${module.foundation.openvpn_public_fqdn}
            ${module.foundation.openvpn_public_ip}
  Username: ${var.openvpn_admin_user}
  Password: ${var.openvpn_admin_pw}

You can administer the OpenVPN Access Server:
  https://${module.foundation.openvpn_public_fqdn}/admin
  https://${module.foundation.openvpn_public_ip}/admin

CONFIGURATION
}
