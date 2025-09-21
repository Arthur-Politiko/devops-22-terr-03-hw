data "yandex_compute_image" "db_image" {
  # "https://yandex.cloud/ru/search?q=yandex_compute_image&type=all"
  # image_id, family or name must be specified.
  family = var.default_image_family_name
}

resource "yandex_compute_instance" "db" {
  # toset не сработает, внутри объект
  # прийдётся использовать for. vm.vm_name => vm создаём map, где ключ vm_name
  # то есть после работы for_each получаем объект вида:
  #   "main"     = { vm_name = "main", ...
  #   "replica"  = { vm_name = "replica", ...
  for_each = { for vm in var.db_vms : vm.vm_name => vm }
  #for_each = [ for k, v in var.db_vms : v ]

  name = each.value.vm_name
  hostname = each.value.vm_name
  
  platform_id = var.default_platform_name
  zone = var.default_zone

  resources {
    cores = each.value.cpu   # 
    memory = each.value.ram  #
    core_fraction = var.default_resources.core_fraction #
  }
  metadata = {
    serial-port-enable =  var.default_metadata.serial-port-enable
    ssh-keys = "${var.default_metadata.user}:${file(var.default_metadata.filepath)}"
  }
  boot_disk {
    initialize_params {
      # https://yandex.cloud/ru/docs/terraform/data-sources/compute_instance#nested-schema-for6
      image_id = data.yandex_compute_image.db_image.image_id
      size     = each.value.disk_volume  # GB
      #type     = "network-hdd"  # "network-ssd"
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
}