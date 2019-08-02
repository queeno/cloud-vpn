
data "google_project" "project" {}
data "google_compute_zones" "available" {}

data "google_compute_image" "container_os" {
  family  = "cos-69-lts"
  project = "cos-cloud"
}

data "template_file" "init_script" {
  template = file("init-script.tpl")
  vars = {
    hostname = var.vm_name
    dns_name = local.dns_name
  }
}

data "template_cloudinit_config" "config" {
  gzip = false
  base64_encode = false

  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content = data.template_file.init_script.rendered
  }
}

resource "google_compute_instance" "uk_vpn" {
  name         = "uk-vpn"
  machine_type = "n1-standard-1"
  zone         = data.google_compute_zones.available.names[0]

  tags = ["vpn"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.container_os.self_link
    }
  }

  metadata = {
    sshKeys = "simon:${file(var.ssh_pub_key_file)}"
    user-data = data.template_cloudinit_config.config.rendered
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vpc_subnetwork.self_link

    access_config {
      network_tier = "STANDARD"
      nat_ip = google_compute_address.static.address
    }
  }
}