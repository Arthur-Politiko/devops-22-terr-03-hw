locals {
  vms = {
    #webservers = length(yandex_compute_instance.web) == 0 ? {} : { for i in yandex_compute_instance.web: i.name => i},
    #databases = length(yandex_compute_instance.db) == 0 ? {} : {for k, v in yandex_compute_instance.db: k => v },
    #storage = can(yandex_compute_instance.storage) && length(yandex_compute_instance.storage) == 0 ? {} : { for i in yandex_compute_instance.storage: i.name => i},
    webservers = length(yandex_compute_instance.web) == 0 ? {} : { for i in yandex_compute_instance.web: i.name => i},
    #databases = yandex_compute_instance.db,
    databases = length(yandex_compute_instance.db) == 0 ? {} : {for k, v in yandex_compute_instance.db: k => v },
    #storage = yandex_compute_instance.storage,
    storage = length(yandex_compute_instance.storage.*) == 0 ? {} : { for i in yandex_compute_instance.storage.*: i.name => i},
  }

  vms_flat = concat(
    length(yandex_compute_instance.web) == 0 ? [] : 
      [for i in yandex_compute_instance.web: i], 
    length(yandex_compute_instance.db) == 0 ? [] : 
      [for i in yandex_compute_instance.db: i],
    length(yandex_compute_instance.storage) == 0 ? [] : yandex_compute_instance.storage.*,
  )
}

resource "local_file" "inventory" {
  depends_on = [ yandex_compute_instance.web, yandex_compute_instance.db, yandex_compute_instance.storage ]
  
  # content = templatefile("./hosts.tftpl",
  #   #[for i in local.webservers: i ]
  #   { webservers = local.vms_flat }
  # )

  content = templatefile("./hosts.tftpl",
    #[for i in local.webservers: i ]
    {webservers = local.vms}
  )

  filename = "./inventory.ini"
}
