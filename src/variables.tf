###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "nat_enable" {
  type        = bool
  default     = true
  description = "NAT enable for subnet"
}

variable "default_resources" {
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  description = "Default VM resources"  
}

variable "default_metadata" {
  type = object({
    serial-port-enable = string
    user = string
    filepath = string
  })
  default = {
    filepath = "~/.ssh/id_ed25519.pub"
    user = "ubuntu"
    serial-port-enable = "1"
  }
}

variable "default_platform_name" {
  type        = string
  default     = "standard-v1"
  description = "https://yandex.cloud/ru/docs/compute/concepts/vm-platforms"
}

variable "default_image_family_name" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "https://cloud.yandex.ru/docs/compute/concepts/images"
}

variable "default_scheduling_policy_flag" {
  type        = bool
  default     = true
  description = "Preemptible VM"
  
}


#**********************************************#
variable "web_vm_count" {
  type = number
  default = 2
  description = "Count of web VM"
}

#**********************************************#
variable "db_vms" {
  type = list(object({  
    vm_name = string, cpu = number, ram = number, disk_volume = number }))
  default = [
    { vm_name = "main", cpu = "2", ram = "2", disk_volume = "10" },
    { vm_name = "replica", cpu = "2", ram = "1", disk_volume = "15" }
  ]
  description = "List of db VMs"
}

#**********************************************#
variable "storage_vm" {
  type = object({  
    vm_name = string, cpu = number, ram = number, disk_volume = number })
  default = { vm_name = "storage-1", cpu = 2, ram = 2, disk_volume = 12 }
  description = "Storage VM"
} 

variable "disk_list" {
  type = list(object({  
    disk_name = string, disk_size = number, disk_type = string, disk_zone = string })
    )
  default = [{disk_name = "", disk_size = 1, disk_type = "network-hdd", disk_zone = "ru-central1-a"},
             {disk_name = "", disk_size = 1, disk_type = "network-hdd", disk_zone = "ru-central1-a"}, 
             {disk_name = "", disk_size = 1, disk_type = "network-hdd", disk_zone = "ru-central1-a"}]
  description = "List of disks"             

}