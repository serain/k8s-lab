resource "azurerm_lb" "lb" {
  name                = "k8s-controller-lb"
  location            = "${var.loc}"
  resource_group_name = "${var.rg}"

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${var.pip_id}"
  }
}

resource "azurerm_lb_probe" "lb" {
  resource_group_name = "${var.rg}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "k8s-controller-lb-healthz"
  port                = 80
  protocol            = "Http"
  request_path        = "/healthz"
}

resource "azurerm_lb_backend_address_pool" "lb" {
  resource_group_name = "${var.rg}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "k8s-controller-lb-bepool"
}

resource "azurerm_lb_rule" "lb" {
  resource_group_name            = "${var.rg}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "k8s-controller-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 6443
  backend_port                   = 6443
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.lb.id}"
  probe_id                       = "${azurerm_lb_probe.lb.id}"
}
