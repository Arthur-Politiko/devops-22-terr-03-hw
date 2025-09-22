#создаем/не создаем бастион
resource "yandex_compute_instance" "bastion" {
  #count = alltrue([var.env == "production", var.external_acess_bastion]) ? 1 : 0
  count = var.bastion_enable == true ? 1 : 0

  name        = "bastion" #Имя ВМ в облачной консоли
  hostname    = "bastion" #формирует FDQN имя хоста, без hostname будет сгенрировано случаное имя.
  platform_id = "standard-v1"

  resources {
    cores = var.default_resources.cores   # 
    memory = var.default_resources.memory  #
    core_fraction = var.default_resources.core_fraction #
  }
#   boot_disk {
#     initialize_params {
#       image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
#       type     = "network-hdd"
#       size     = 5
#     }
#   }
  boot_disk {
    initialize_params {
      # https://yandex.cloud/ru/docs/terraform/data-sources/compute_instance#nested-schema-for6
      image_id = data.yandex_compute_image.db_image.image_id
      size     = 5 #each.value.disk_volume  # GB
      type     = "network-hdd"  # "network-ssd"
    }
  }
#   metadata = {
#     ssh-keys = "ubuntu:${var.public_key}"
#   }
  metadata = {
    serial-port-enable =  var.default_metadata.serial-port-enable
    ssh-keys = "${var.default_metadata.user}:${file(var.default_metadata.filepath)}"
  }
#   scheduling_policy { preemptible = true }
  scheduling_policy {
    # конфигурация политики планирования в контексте Yandex Cloud
    # preemptible - прерывание виртуальной машины
    preemptible = var.default_scheduling_policy_flag
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }
  allow_stopping_for_update = true

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.network_interface.0.nat_ip_address #можно конечно и yandex_compute_instance.bastion["network_interface"][0]["nat_ip_address"] но не нужно!
    private_key = file("~/.ssh/id_ed25519")
    timeout     = "120s"
  }
  provisioner "file" {
    source      = "./scripts"
    destination = "/tmp"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/scripts/script.sh",
      "/tmp/scripts/script.sh"
    ]
  }
}