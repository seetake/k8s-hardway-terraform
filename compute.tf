resource "google_compute_instance" "k8s_controller" {
  boot_disk {
    auto_delete = true

    initialize_params {
      image = "${var.controller_image}"
      size  = "${var.controller_size}"
    }
  }

  can_ip_forward = true
  count          = "${var.controller_count}"
  machine_type   = "${var.controller_type}"
  name           = "controller-${count.index}"

  network_interface {
    access_config {}
    subnetwork    = "${google_compute_subnetwork.k8s_subnet.name}"
    network_ip    = "10.240.0.1${count.index}"
  }

  metadata = {
    creator = "${var.user}"
  }

  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  tags = ["controller"]
  zone = "${var.zone}"
}

resource "google_compute_instance" "k8s_worker" {
  boot_disk {
    auto_delete = true

    initialize_params {
      image = "${var.worker_image}"
      size  = "${var.worker_size}"
    }
  }

  can_ip_forward = true
  count          = "${var.worker_count}"
  machine_type   = "${var.worker_type}"
  name           = "worker-${count.index}"

  network_interface {
    access_config {}
    subnetwork    = "${google_compute_subnetwork.k8s_subnet.name}"
    network_ip    = "10.240.0.2${count.index}"
  }

  metadata = {
    creator  = "${var.user}"
    pod-cidr = "10.200.${count.index}.0/24"
  }

  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  tags = ["worker"]
  zone = "${var.zone}"
}