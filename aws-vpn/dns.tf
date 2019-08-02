locals {
  dns_name = "vpn-aws.${data.google_dns_managed_zone.norix.dns_name}"
}

data "google_dns_managed_zone" "norix" {
  provider    = "google"
  name        = "norix"
}

resource "google_dns_record_set" "dns" {
  provider = "google"
  name = local.dns_name
  type = "A"
  ttl  = 5

  managed_zone = data.google_dns_managed_zone.norix.name

  rrdatas = [aws_eip.ip.public_ip]
}