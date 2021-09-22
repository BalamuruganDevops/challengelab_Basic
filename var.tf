variable "location" {
  type = string
  default = "eastus2"
}

variable "resource_group_name" {
    type = string
    default = "Basicdevopsbala"
}


### Network Variables

variable "virtual_network_name" {
  type = string
  default     = "Basicdevopsbala-vnet"
}

variable "subnet_name" {
  type = string
  default     = "Basicdevopsbala-subnet"
}

variable "public_ip_name" {
  type = string
  default     = "Basicdevopsbala-pip"
}

variable "network_security_group_name" {
  default     = "Basicdevopsbala-SG"
}

variable "network_interface_name" {
  type = string
  default     = "Basicdevopsbala-nic"
}

### Virtual Machine Variables

variable "virtual_machine_name" {
  default     = "Basicdevopsbala-VM"
}

variable "virtual_machine_size" {
  default     = "Standard_B2ms"
}

variable "virtual_machine_osdisk_name" {
  default     = "Basicdevopsbala-osdisk"
}

variable "virtual_machine_osdisk_type" {
  default     = "Standard_LRS"
}

variable "virtual_machine_computer_name" {
  default     = "Basicdevopsbalacomp-VM"
}

variable "admin_username" {
  default     = "vmadmin"
}

variable "admin_password" {
  default     = "April@123456789"
}