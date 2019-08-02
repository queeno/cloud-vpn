locals {
  dns_name = "vpn.${data.google_dns_managed_zone.norix.dns_name}"
}

data "google_dns_managed_zone" "norix" {
  name        = "norix"
}

resource "google_dns_record_set" "dns" {
  name = local.dns_name
  type = "A"
  ttl  = 5

  managed_zone = data.google_dns_managed_zone.norix.name

  rrdatas = [google_compute_instance.uk_vpn.network_interface[0].access_config[0].nat_ip]
}