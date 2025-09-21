data "yandex_compute_image" "web_image" {
  # "https://yandex.cloud/ru/search?q=yandex_compute_image&type=all"
  # image_id, family or name must be specified.
  family = var.default_image_family_name
}

resource "yandex_compute_instance" "web" {
  count = var.web_vm_count
  name = "web-${count.index + 1}"
  hostname = "web-${count.index + 1}"
  platform_id = var.default_platform_name
  zone = var.default_zone

  resources {
    cores = var.default_resources.cores   # 
    memory = var.default_resources.memory  #
    core_fraction = var.default_resources.core_fraction #
  }
  metadata = {
    serial-port-enable =  var.default_metadata.serial-port-enable
    ssh-keys = "${var.default_metadata.user}:${file(var.default_metadata.filepath)}"
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.web_image.image_id
    }
  }
  scheduling_policy {
    # конфигурация политики планирования в контексте Yandex Cloud
    # preemptible - прерывание виртуальной машины
    preemptible = var.default_scheduling_policy_flag
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.nat_enable
    # https://terraform-provider.yandexcloud.net/resources/compute_instance
    security_group_ids = [yandex_vpc_security_group.example.id]
  }
  depends_on = [ yandex_compute_instance.db ]
}