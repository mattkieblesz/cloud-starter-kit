variable "domain"            { }
variable "name"              { }
variable "iam_admins"        { }


module "iam_admin" {
  source = "../../modules/terraform/util/iam"

  name       = "${var.name}-admin"
  users      = "${var.iam_admins}"
  policy     = <<EOF
{
  "Version"  : "2012-10-17",
  "Statement": [
    {
      "Effect"  : "Allow",
      "Action"  : "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_route53_zone" "zone" {
  name = "${var.domain}"
}
