terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.20.0"
    }
  }
}

data "external" "my_ip" {
  program = ["bash", "-c", "curl -s https://wtfismyip.com/json | jq '{ip: .YourFuckingIPAddress}'"]
}

output "my_ip" {
  value = data.external.my_ip.result.ip
}

provider "google" {
  project = "gcp-headstart-educative-414223"
  region  = "us-central1"
  zone    = "us-central1-f"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_instance"  "micro-1" {
  name         = "micro-1"
  machine_type = "e2-micro"
  zone         = "us-central1-f"
  tags =  ["ssh-enabled"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-13"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.id
    access_config {}
  }
}

resource "google_compute_instance"  "micro-2" {
  name         = "micro-2"
  machine_type = "e2-micro"
  zone         = "us-central1-f"
  tags =  ["ssh-enabled"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-13"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.id
    access_config {}
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${data.external.my_ip.result.ip}/32"]

  target_tags = ["ssh-enabled"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"  # or "EXCLUDE_ALL_METADATA" to reduce cost
  }
}