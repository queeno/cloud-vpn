resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_network" "vpc_network" {
  name                    = "simons-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name                     = "default-${var.region}"
  region                   = var.region
  private_ip_google_access = true
  ip_cidr_range            = "10.156.0.0/20"
  network                  = google_compute_network.vpc_network.self_link

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.156.16.0/20"
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.156.32.0/27"
  }

}

resource "google_compute_router" "vpc_router" {
  name    = "default-${var.region}"
  region  = google_compute_subnetwork.vpc_subnetwork.region
  network = google_compute_network.vpc_network.self_link
}

resource "google_compute_router_nat" "simple-nat" {
  name                               = "default-${var.region}-nat"
  router                             = google_compute_router.vpc_router.name
  region                             = google_compute_subnetwork.vpc_subnetwork.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "firewall" {
  name    = "allow-ssh-vpn-to-vpn-vm"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports = ["443"]
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["vpn"]
}