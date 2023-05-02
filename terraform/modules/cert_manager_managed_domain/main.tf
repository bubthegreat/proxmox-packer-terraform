
resource "aws_route53domains_registered_domain" "aws_registered_domain" {
  domain_name = "${var.domain_name}"
}

data "aws_route53_zone" "aws_domain" {
  name         = "${var.domain_name}"
  private_zone = false
}

resource "aws_route53_record" "ns_record" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.aws_domain.zone_id
  name    = "${var.domain_name}"
  type    = "NS"
  ttl     = "30"
  records = [
    aws_route53domains_registered_domain.aws_registered_domain.name_server[0].name,
    aws_route53domains_registered_domain.aws_registered_domain.name_server[1].name,
    aws_route53domains_registered_domain.aws_registered_domain.name_server[2].name,
    aws_route53domains_registered_domain.aws_registered_domain.name_server[3].name
  ]
}

resource "aws_route53_record" "wildcard_record" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.aws_domain.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"
  ttl     = "30"
  records = ["${var.public_cluster_ip}"]
}

resource "aws_route53_record" "main_record" {
  allow_overwrite = true
  zone_id = data.aws_route53_zone.aws_domain.zone_id
  name    = "${var.domain_name}"
  type    = "A"
  ttl     = "30"
  records = ["${var.public_cluster_ip}"]
}
