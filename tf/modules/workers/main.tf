resource "azurerm_network_interface" "nic" {
  count                             = "${var.count}"
            
  name                              = "k8s-worker-nic-${count.index}"
  location                          = "${var.loc}"
  resource_group_name               = "${var.rg}"
 
  ip_configuration { 
    name                            = "k8s-worker-vip-${count.index}"
    subnet_id                       = "${var.sub_id}"
    private_ip_address_allocation   = "dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  count                             = "${var.count}"
  
  name                              = "k8s-worker-vm-${count.index}"
  location                          = "${var.loc}"
  resource_group_name               = "${var.rg}"

  vm_size                           = "${var.vm_size}"
  network_interface_ids             = [
    "${element(azurerm_network_interface.nic.*.id, count.index)}"
    ]
  
  delete_os_disk_on_termination     = true
  delete_data_disks_on_termination  = true
 
  storage_image_reference { 
    publisher                       = "Canonical"
    offer                           = "UbuntuServer"
    sku                             = "18.04-LTS"
    version                         = "latest"
  } 
 
  storage_os_disk { 
    name                            = "k8s-worker-dsk-${count.index}"
    caching                         = "ReadWrite"
    create_option                   = "FromImage"
    managed_disk_type               = "Standard_LRS"
  } 
 
  os_profile { 
    computer_name                   = "k8s-worker-vm-${count.index}"
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
