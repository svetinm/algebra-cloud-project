resource "azurerm_network_interface" "jump_nic" {
  name                = "jump-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "jump-ip-config"
    subnet_id                     = azurerm_subnet.jump_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jump_pip.id
  }

  tags = local.tags
}

resource "azurerm_windows_virtual_machine" "jump" {
  name                  = "jump-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.jump_nic.id]
  size                  = "Standard_B2ats_v2"

  admin_username = "azureuser"
  # VAŽNO: Promijeni lozinku prije deploymenta!
  admin_password = "P@ssw0rd!Algebra2026"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  patch_mode = "AutomaticByPlatform"

  lifecycle {
    ignore_changes = [size]
  }

  tags = local.tags
}
