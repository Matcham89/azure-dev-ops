#
# network 
#
resource "azurerm_virtual_network" "v_network" {
  name                = "ramsay-network"
  address_space       = ["10.0.0.0/16"]
  location            = local.resource_location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.v_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "v_network_int_1" {
  name                = "ramsay-nic-1"
  location            = local.resource_location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "v_network_int_2" {
  name                = "ramsay-nic-2"
  location            = local.resource_location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
#
# virtual machine
#

resource "azurerm_linux_virtual_machine" "linux_vm_1" {
  name                = "ramsay-machine-1"
  location            = local.resource_location
  resource_group_name = var.resource_group
  size                = "Standard_F1"
  admin_username      = "adminuser"
  admin_password                  = azurerm_key_vault_secret.linux_vm_1_secret.value
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.v_network_int_1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

#
# virtual machine
#

resource "azurerm_linux_virtual_machine" "linux_vm_2" {
  name                = "ramsay-machine-2"
  location            = local.resource_location
  resource_group_name = var.resource_group
  size                = "Standard_F1"
  admin_username      = "adminuser"
  admin_password                  = azurerm_key_vault_secret.linux_vm_1_secret.value
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.v_network_int_2.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}