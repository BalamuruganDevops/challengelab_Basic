provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "pip" {
  name                = var.public_ip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

data "azurerm_public_ip" "pip" {
    name                = azurerm_public_ip.pip.name
    resource_group_name = azurerm_public_ip.pip.resource_group_name
    depends_on          = [azurerm_public_ip.pip]
}

output "pip" {
       value = "${data.azurerm_public_ip.pip.ip_address}"
   }

resource "azurerm_network_security_group" "allows" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allall"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                      = var.network_interface_name
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  
  ip_configuration {
    name                          = "${var.network_interface_name}-configuration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

#VM Creation 
resource "azurerm_virtual_machine" "vm" {
  name                  = var.virtual_machine_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = var.virtual_machine_size

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = var.virtual_machine_osdisk_name
    create_option     = "FromImage"
    managed_disk_type = var.virtual_machine_osdisk_type
  }

  os_profile {
    computer_name  = var.virtual_machine_computer_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
   os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "remote-exec" {
  inline = [
      "sudo yum -y install httpd && sudo systemctl start httpd",
      "echo '<h1><center>My first website using terraform provisioner</center></h1>' > index.html",
      "echo '<h1><center>Jorge Gongora</center></h1>' >> index.html",
      "sudo mv index.html /var/www/html/"
    ]
  connection {
      type = "ssh"
      user = var.admin_username
      password = var.admin_password
      host = data.azurerm_public_ip.pip.ip_address
  }
  }
}
