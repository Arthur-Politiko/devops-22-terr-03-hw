# Yandex Compute Disk
# https://yandex.cloud/ru/docs/compute/operations/images-with-pre-installed-software/create

resource "yandex_compute_disk" "disks" {
  count = length(var.disk_list)  # количество дисков равно длинне списка из переменной
  name = length(var.disk_list[count.index].disk_name) == 0 ? "disk-${count.index + 1}" : var.disk_list[count.index].disk_name # имя диска с суффиксом из имени ВМ
  type = var.disk_list[count.index].disk_type # 
  size = var.disk_list[count.index].disk_size # 
  #zone = var.disk_list[count.index].disk_zone # 
  zone = var.default_zone # 
}

# data "yandex_compute_disk" "creaed_disks" {
# }

resource "yandex_compute_instance" "storage" {
  name = var.storage_vm.vm_name
  hostname = var.storage_vm.vm_name
  platform_id = var.default_platform_name
  zone = var.default_zone
  resources {
    cores = var.storage_vm.cpu   # 
    memory = var.storage_vm.ram  #
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
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.disks
    content {
      disk_id = secondary_disk.value.id
    }
  }
  scheduling_policy {
    preemptible = var.default_scheduling_policy_flag
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.nat_enable
    security_group_ids = [yandex_vpc_security_group.example.id]
  }
  depends_on = [ yandex_compute_instance.db ]
}

