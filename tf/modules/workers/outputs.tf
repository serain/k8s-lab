data "template_file" "name_tpl" {
    count    = "${var.count}"
    template = "$${name} private_ip=$${private_ip} pod_cidr=$${pod_cidr}"
    vars {
        name = "${azurerm_virtual_machine.vm.*.name[count.index]}"
        private_ip = "${azurerm_network_interface.nic.*.private_ip_address[count.index]}"
        pod_cidr = "${var.pod_cidr_prefix}.${count.index}.0/24"
    }
}

output "names" {
    value    = "${join("\n", data.template_file.name_tpl.*.rendered)}"
}
