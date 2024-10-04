provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# Groupe de ressources
resource "azurerm_resource_group" "cr460_group" {
  name     = "CR460"
  location = "East US" 
}

# Réseau virtuel
resource "azurerm_virtual_network" "cr460_vnet" {
  name                = "CR460-VNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.cr460_group.location
  resource_group_name = azurerm_resource_group.cr460_group.name
}

# Machine virtuelle
resource "azurerm_linux_virtual_machine" "cr460_vm" {
  name                = "CR460-VM"
  resource_group_name = azurerm_resource_group.cr460_group.name
  location            = azurerm_resource_group.cr460_group.location
  size                = "Standard_B1s"

  network_interface_ids = [azurerm_network_interface.cr460_nic.id]

  admin_username = "userCR460"  
  admin_password = "Password1234!"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Interface réseau
resource "azurerm_network_interface" "cr460_nic" {
  name                = "CR460-NIC"
  location            = azurerm_resource_group.cr460_group.location
  resource_group_name = azurerm_resource_group.cr460_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cr460_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Subnet
resource "azurerm_subnet" "cr460_subnet" {
  name                 = "CR460-Subnet"
  resource_group_name  = azurerm_resource_group.cr460_group.name
  virtual_network_name = azurerm_virtual_network.cr460_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
