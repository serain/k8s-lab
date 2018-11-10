data "template_file" "name_tpl" {
    count    = "${var.count}"
    template = "$${name} private_ip=$${private_ip}"
    vars {
        name = "${azurerm_virtual_machine.vm.*.name[count.index]}"
        private_ip = "${azurerm_network_interface.nic.*.private_ip_address[count.index]}"
    }
}

output "names" {
    value    = "${join("\n", data.template_file.name_tpl.*.rendered)}"
}
