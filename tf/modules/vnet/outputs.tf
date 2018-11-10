output "rg"   { value = "${azurerm_resource_group.rg.name}" }
output "name" { value = "${azurerm_virtual_network.vnet.name}" }
output "k8s_controller_sub_id" { value = "${azurerm_subnet.k8s_controller_sub.id}"}
output "k8s_worker_sub_id" { value = "${azurerm_subnet.k8s_worker_sub.id}"}
output "k8s_api_pip_address" { value = "${azurerm_public_ip.k8s_api_pip.ip_address}"}
output "k8s_api_pip_id" { value = "${azurerm_public_ip.k8s_api_pip.id}"}
output "jumpbox_sub_id" { value = "${azurerm_subnet.jumpbox_sub.id}"}
output "jumpbox_pip_id" { value = "${azurerm_public_ip.jumpbox_pip.id}"}

data "template_file" "ssh_config_tpl" {
    template = <<EOF
Host jumpbox
    User kadmin
    HostName $${jumpbox}
    BatchMode yes
    PasswordAuthentication no
    StrictHostKeyChecking no
    ControlMaster auto
    ControlPath /tmp/ssh_control-%r@%h:%p
    ControlPersist 2h
    UserKnownHostsFile=/dev/null
    ServerAliveInterval 30
    ServerAliveCountMax 10

Host * !jumpbox
    User kadmin
    ServerAliveInterval 30
    ServerAliveCountMax 10
    TCPKeepAlive yes
    StrictHostKeyChecking no
    ProxyCommand ssh -q -F ssh_config -W %h:%p jumpbox
    ControlMaster auto
    ControlPath /tmp/ssh_control-%r@%h:%p
    ControlPersist 2h
    UserKnownHostsFile=/dev/null
EOF

    vars {
        jumpbox = "${azurerm_public_ip.jumpbox_pip.ip_address}"
    }
}

output "ssh_config" {
    value    = "${data.template_file.ssh_config_tpl.rendered}"
}
