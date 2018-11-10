output "ssh_config" {
    value = "${module.vnet.ssh_config}"
    sensitive = true
}

data "template_file" "ansible_hosts_tpl" {
    template = <<EOF
[workers]
$${workers}

[controllers]
$${controllers}

[jbox]
jumpbox

[all:vars]
ansible_python_interpreter=/usr/bin/python3
k8s_public_ip=$${api_pip}
EOF

    vars {
    workers = "${module.workers.names}"
    controllers = "${module.controllers.names}"
    api_pip = "${module.vnet.k8s_api_pip_address}"
  }
}

output "ansible_hosts" {
  value     = "${data.template_file.ansible_hosts_tpl.rendered}"
  sensitive = true
}
