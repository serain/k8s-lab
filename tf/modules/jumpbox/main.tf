resource "azurerm_network_interface" "nic" {
  name                              = "jumpbox-nic"
  location                          = "${var.loc}"
  resource_group_name               = "${var.rg}"
 
  ip_configuration { 
    name                            = "jumpbox-vip"
    subnet_id                       = "${var.sub_id}"
    private_ip_address_allocation   = "dynamic"
    public_ip_address_id            = "${var.pip_id}"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                              = "jumpbox-vm"
  location                          = "${var.loc}"
  resource_group_name               = "${var.rg}"
  vm_size                           = "${var.vm_size}"
  network_interface_ids             = ["${azurerm_network_interface.nic.id}"]
  
  delete_os_disk_on_termination     = true
  delete_data_disks_on_termination  = true
 
  storage_image_reference { 
    publisher                       = "Canonical"
    offer                           = "UbuntuServer"
    sku                             = "18.04-LTS"
    version                         = "latest"
  } 
 
  storage_os_disk { 
    name                            = "jumpbox-dsk"
    caching                         = "ReadWrite"
    create_option                   = "FromImage"
    managed_disk_type               = "Standard_LRS"
  } 
 
  os_profile { 
    computer_name                   = "jumpbox-vm"
    admin_username                  = "${var.vm_user}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path                          = "/home/${var.vm_user}/.ssh/authorized_keys"
      key_data                      = "${var.vm_ssh_key}"
    }
  }
}
