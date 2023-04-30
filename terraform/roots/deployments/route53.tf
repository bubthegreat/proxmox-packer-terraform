# TODO: Maybe make this optional?  This won't prevent things from deploying but it will
# mean you won't be able to see TLS for quite some time when it's done building.

data "aws_route53_zone" "aws_domain" {
  name         = var.aws_domain
  private_zone = false
}

resource "aws_iam_user" "cert_manager_user" {
  name = "svc-cert-manager" # Needs to be from var
}

resource "aws_iam_access_key" "my_access_key" {
  user = aws_iam_user.cert_manager_user.name
}

data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

# Updates to add the medium record.
 # Needs to be from var - list of records you want, default to just the wildcard
resource "aws_route53_record" "medium_record" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.aws_domain.zone_id
  name    = "${data.aws_route53_zone.aws_domain.name}"
  type    = "A"
  ttl     = "30"
  records = ["162.159.153.4"]
}

resource "aws_route53_record" "wildcard_record" {
  zone_id = data.aws_route53_zone.aws_domain.zone_id
  name    = "*.${data.aws_route53_zone.aws_domain.name}"
  type    = "A"
  ttl     = "30"
  records = ["${data.external.myipaddr.result.ip}"]
}

# TODO: This policy needs to be pared down to just the domain that this is for
# so you don't have a service account that can modify all your domains.
resource "aws_iam_user_policy" "cert_manager_user_policy" {
  name = "cert-manager-policy"
  user = aws_iam_user.cert_manager_user.name
policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*"
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
EOF
}