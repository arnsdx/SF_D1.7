terraform {
  required_version = ">= 1.8.5"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.121.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = "path_to_key_file"
  cloud_id                 = "cloud_id"
  folder_id                = "folder_id"
  zone                     = "ru-central1-a"
}

resource "yandex_compute_image" "ubuntu-image" {
  source_family = "ubuntu-2404-lts-oslogin"
  min_disk_size = 10 
}

resource "yandex_vpc_network" "sf-d1-network" {}

resource "yandex_vpc_subnet" "sf-d1-default-subnet" {
  network_id     = yandex_vpc_network.sf-d1-network.id
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.136.11.0/24"]
}

resource "yandex_compute_instance" "master" {
  name     = "sf-d1-master"
  hostname = "sf-d1-master"

  resources {
    cores  = 2
    memory = 8
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = resource.yandex_compute_image.ubuntu-image.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sf-d1-default-subnet.id
    nat    = true
  }
  metadata = {
    ssh-keys  = "arnsdx-admin:${file("~/.ssh/id_yandex.pub")}"
    user-data = "#cloud-config\ndatasource:\n Ec2:\n  strct_id: false\nssh_pwauth: no\nusers:\n- name: admin_account\n  sudo: ALL=(ALL) NOPASSWD:ALL\n  shell: /bin/bash\n  ssh_authorized_keys:\n  - ssh-rsa_pub_key\n#cloud-config\nruncmd: []"
  }

  timeouts {
    create = "60m"
    delete = "60m"
  }
}

resource "yandex_compute_instance" "worker-1" {
  name     = "sf-d1-worker-1"
  hostname = "sf-d1-worker-1"

  resources {
    cores  = 2
    memory = 8
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = resource.yandex_compute_image.ubuntu-image.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sf-d1-default-subnet.id
    nat    = true
  }
  metadata = {
    ssh-keys  = "arnsdx-admin:${file("~/.ssh/id_yandex.pub")}"
    user-data = "#cloud-config\ndatasource:\n Ec2:\n  strict_id: false\nssh_pwauth: no\nusers:\n- name: arnsdx-admin\n  sudo: ALL=(ALL) NOPASSWD:ALL\n  shell: /bin/bash\n  ssh_authorized_keys:\n  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDE/bWEwub/9IXYtbHyFp8GBlOQSvCPG7OPalfuw/791ETWkmShNrUM5Edo7Cjzl5+FhqzM+RJj/Tvve0V1CLaQEKkgmONJ92PrZaMB+F1p/0651KOvk6+z7X++ulb9Cz4tC3zeW2Yw7Lb9ShAQlWN+7Z9lQqjBor5SaE/QKYssGafIIZaafupsg7WuOqg22+5SwyrgM6QKWvo/3dAkhafqR62XERVavWt2/g2UdUYkNVbS3r7ZsWgf+W99GtH4IFHczKEPq72GawCSz75j6fth2H5Sn1KRsw2dwxcbC7RKbUAjejleoncIkNts6MlGFRWq66sLUAOyWZbJUwf7ir1qXWJdPreOtkoSZaQuJchSoQP4Wmr74wFy19h64R7ZV7yoEr02B5wWP+i8TVoD8No33XKEYTjUAxhKcdwddfDVtAVUdj+dIVkH5Qr1bg6JgSnwSuId3iv0WN5yFvMbdy9yK2/SrCOQN2ChKVV37/r6JxCD04JJnw4wxEIDAjy4GX1Ea6QCisQr7orOjS14gTVWjYYeQCSpMoChmYMTjPpt/h1Pu+dadnxQU1bWkPzeK7TBBLrokf5w549CM1ng7sw2482gr4OFEjMM+W/X3jjpkQbgtExBAbAjAHz8EJQVXyHJRabC/DBBIXGOn+EcMeUsC01mvE86KOwPFBb0ZX0Z7w==\n#cloud-config\nruncmd: []"
  }

  timeouts {
    create = "60m"
    delete = "60m"
  }
}

resource "yandex_compute_instance" "worker-2" {
  name     = "sf-d1-vm2"
  hostname = "sf-d1-vm2"

  resources {
    cores  = 2
    memory = 8
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
    image_id = resource.yandex_compute_image.ubuntu-image.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sf-d1-default-subnet.id
    nat    = true
  }
  metadata = {
    ssh-keys  = "arnsdx-admin:${file("~/.ssh/id_yandex.pub")}"
    user-data = "#cloud-config\ndatasource:\n Ec2:\n  strict_id: false\nssh_pwauth: no\nusers:\n- name: arnsdx-admin\n  sudo: ALL=(ALL) NOPASSWD:ALL\n  shell: /bin/bash\n  ssh_authorized_keys:\n  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDE/bWEwub/9IXYtbHyFp8GBlOQSvCPG7OPalfuw/791ETWkmShNrUM5Edo7Cjzl5+FhqzM+RJj/Tvve0V1CLaQEKkgmONJ92PrZaMB+F1p/0651KOvk6+z7X++ulb9Cz4tC3zeW2Yw7Lb9ShAQlWN+7Z9lQqjBor5SaE/QKYssGafIIZaafupsg7WuOqg22+5SwyrgM6QKWvo/3dAkhafqR62XERVavWt2/g2UdUYkNVbS3r7ZsWgf+W99GtH4IFHczKEPq72GawCSz75j6fth2H5Sn1KRsw2dwxcbC7RKbUAjejleoncIkNts6MlGFRWq66sLUAOyWZbJUwf7ir1qXWJdPreOtkoSZaQuJchSoQP4Wmr74wFy19h64R7ZV7yoEr02B5wWP+i8TVoD8No33XKEYTjUAxhKcdwddfDVtAVUdj+dIVkH5Qr1bg6JgSnwSuId3iv0WN5yFvMbdy9yK2/SrCOQN2ChKVV37/r6JxCD04JJnw4wxEIDAjy4GX1Ea6QCisQr7orOjS14gTVWjYYeQCSpMoChmYMTjPpt/h1Pu+dadnxQU1bWkPzeK7TBBLrokf5w549CM1ng7sw2482gr4OFEjMM+W/X3jjpkQbgtExBAbAjAHz8EJQVXyHJRabC/DBBIXGOn+EcMeUsC01mvE86KOwPFBb0ZX0Z7w==\n#cloud-config\nruncmd: []"
  }

  timeouts {
    create = "60m"
    delete = "60m"
  }
}

output "external_ip_master" {
    value = yandex_compute_instance.master.network_interface[0].nat_ip_address
}
output "external_ip_worker-2" {
    value = yandex_compute_instance.worker-2.network_interface[0].nat_ip_address
}
output "external_ip_worker-1" {
    value = yandex_compute_instance.worker-1.network_interface[0].nat_ip_address
}
output "internal_ip_master" {
    value = yandex_compute_instance.master.network_interface[0].ip_address
}
output "internal_ip_worker-2" {
    value = yandex_compute_instance.worker-2.network_interface[0].ip_address
}

output "internal_ip_worker-1" {
    value = yandex_compute_instance.worker-1.network_interface[0].ip_address
}