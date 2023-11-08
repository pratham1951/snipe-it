#Resource Group
resource "azurerm_resource_group" "pratham" {
  name     = "pratham"
  location = var.location
}

resource "azurerm_public_ip" "Public_IP" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.pratham.location
  resource_group_name = azurerm_resource_group.pratham.name
  allocation_method   = "Dynamic"
}
#virtual network
resource "azurerm_virtual_network" "pratham-vnet" {
  name                = "pratham-network"
  resource_group_name = azurerm_resource_group.pratham.name
  location            = azurerm_resource_group.pratham.location
  address_space       = ["10.0.0.0/16"]
}

#Subnet
resource "azurerm_subnet" "pratham-subnet" {
  name                 = "pratham-subnet"
  resource_group_name  = azurerm_resource_group.pratham.name
  virtual_network_name = azurerm_virtual_network.pratham-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
#Network Interface
resource "azurerm_network_interface" "pratham-main" {
  name                = "pratham-nic"
  location            = azurerm_resource_group.pratham.location
  resource_group_name = azurerm_resource_group.pratham.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.pratham-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          =  azurerm_public_ip.Public_IP.id
  }
}
#Security Group
resource "azurerm_network_security_group" "pratham-nsg" {
  name                = "my-nsg"
  location            = azurerm_resource_group.pratham.location
  resource_group_name = azurerm_resource_group.pratham.name

  security_rule {
    name                       = "allow-all-traffic"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_linux_virtual_machine" "Pratham" {
  name                  = "Pratham"
  location              = azurerm_resource_group.pratham.location
  resource_group_name   = azurerm_resource_group.pratham.name
  network_interface_ids = [azurerm_network_interface.pratham-main.id]
  size                  = "Standard_B1s"

  // Virtual Machine Disk Details
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  // Virtual Machine Image Details
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name                   = "snipeit"
  admin_username                  = var.admin_username
  disable_password_authentication = true
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh//snipe-it-key.pub")
  }

  connection {
    type        = "ssh"
    user        = var.admin_username        # SSH username for the VM
    private_key = file("~/.ssh//snipe-it-key") # SSH private key file
    host        = self.public_ip_address
  }
   // Copying file from our local machine to Azure VM
  provisioner "file" {
    source      = "./install-snipe-it.sh"
    destination = "/home/ubuntu/install-snipe-it.sh"
  }

   provisioner "remote-exec" {
    inline = [
      "sudo chmod 755 /home/ubuntu/install-snipe-it.sh",
      "cd /home/ubuntu/",
      "sudo apt update",
      "sudo apt install dos2unix -y",
      "dos2unix install-snipe-it.sh",
      "sudo apt purge dos2unix -y",
      "sudo ./install-snipe-it.sh",
    ]
  }
}
