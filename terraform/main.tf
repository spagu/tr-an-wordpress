provider "google" {
  project = "tr-an-wordpress"
  region  = "europe-west2"
}

resource "google_compute_instance" "default" {
  project      = "tr-an-wordpress"
  zone         = "europe-west2-a"
  name         = "wordpress-compute"
  machine_type = "f1-micro"
  tags         = ["http-server"]

  boot_disk {
    initialize_params {
      image = "daily-ubuntu-1604-xenial-v20200320"
    }
  }

  network_interface {
    network = "default"

    access_config = {
      nat_ip = "NEEDS_TO_BE_SET"
    }
  }

  provisioner "local-exec" {
    command = "sleep 20;ansible-playbook -i ${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}, ../ansible/playbook.yml -u root"
  }
}