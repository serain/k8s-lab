module "vnet" {
  source              = "../modules/vnet"

  project             = "${var.project}"
  loc                 = "${var.loc}"
  k8s_controller_cidr = "${var.k8s_controller_cidr}"
  k8s_worker_cidr     = "${var.k8s_worker_cidr}"
  jumpbox_cidr        = "${var.jumpbox_cidr}"

  worker_count        = "${var.k8s_worker_vm_count}"
  worker_cidr_prefix  = "${var.k8s_worker_cidr_prefix}"
  pod_cidr_prefix     = "${var.pod_cidr_prefix}"
}

module "controllers" {
  source             = "../modules/controllers"

  rg                 = "${module.vnet.rg}"
  loc                = "${var.loc}"
  sub_id             = "${module.vnet.k8s_controller_sub_id}"
  count              = "${var.k8s_controller_vm_count}"

  vm_size            = "${var.k8s_controller_vm_size}"
  vm_user            = "${var.vm_user}"
  vm_ssh_key         = "${var.vm_ssh_key}"

  bepool_id          = "${module.loadbalancer.bepool_id}"
}

module "workers" {
  source             = "../modules/workers"

  rg                 = "${module.vnet.rg}"
  loc                = "${var.loc}"
  sub_id             = "${module.vnet.k8s_worker_sub_id}"
  count              = "${var.k8s_worker_vm_count}"

  pod_cidr_prefix    = "${var.pod_cidr_prefix}"

  vm_size            = "${var.k8s_worker_vm_size}"
  vm_user            = "${var.vm_user}"
  vm_ssh_key         = "${var.vm_ssh_key}"
}

module "jumpbox" {
  source             = "../modules/jumpbox"

  rg                 = "${module.vnet.rg}"
  loc                = "${var.loc}"
  sub_id             = "${module.vnet.jumpbox_sub_id}"
  pip_id             = "${module.vnet.jumpbox_pip_id}"

  vm_size            = "${var.jumpbox_vm_size}"
  vm_user            = "${var.vm_user}"
  vm_ssh_key         = "${var.vm_ssh_key}"
}

module "loadbalancer" {
  source             = "../modules/loadbalancer"

  rg                 = "${module.vnet.rg}"
  loc                = "${var.loc}"
  pip_id             = "${module.vnet.k8s_api_pip_id}"
}
