
// Main VNET
resource "azurerm_resource_group" "rg" {
  name                = "${var.project}-${terraform.workspace}"
  location            = "${var.loc}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = "${var.loc}"
  address_space       = ["10.0.0.0/8"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

// K8s Controler Subnet
resource "azurerm_subnet" "k8s_controller_sub" {
  name                 = "k8s-controller-sub"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.k8s_controller_cidr}"
}

resource "azurerm_network_security_group" "k8s_controller_sub" {
  name                = "k8s-controller-sub"
  location            = "${var.loc}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "k8s_controller_sub" {
  subnet_id                 = "${azurerm_subnet.k8s_controller_sub.id}"
  network_security_group_id = "${azurerm_network_security_group.k8s_controller_sub.id}"
}

// K8s Worker Subnet
resource "azurerm_subnet" "k8s_worker_sub" {
  name                 = "k8s-worker-sub"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.k8s_worker_cidr}"
}

resource "azurerm_network_security_group" "k8s_worker_sub" {
  name                = "k8s-worker-sub"
  location            = "${var.loc}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet_network_security_group_association" "k8s_worker_sub" {
  subnet_id                 = "${azurerm_subnet.k8s_worker_sub.id}"
  network_security_group_id = "${azurerm_network_security_group.k8s_worker_sub.id}"
}

// Jumpbox Subnet
resource "azurerm_subnet" "jumpbox_sub" {
  name                 = "jumpbox-sub"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.jumpbox_cidr}"
}

resource "azurerm_network_security_group" "jumpbox_sub" {
  name                = "jumpbox-sub"
  location            = "${var.loc}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "allow-ssh-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "jumpbox_sub" {
  subnet_id                 = "${azurerm_subnet.jumpbox_sub.id}"
  network_security_group_id = "${azurerm_network_security_group.jumpbox_sub.id}"
}

// Public IP for Jumpbox
resource "azurerm_public_ip" "jumpbox_pip" {
  name                         = "jumpbox-pip"
  location                     = "${var.loc}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "Static"
  sku                          = "Standard"
}

// Public IP for K8s API
resource "azurerm_public_ip" "k8s_api_pip" {
  name                         = "k8s-api-pip"
  location                     = "${var.loc}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "Static"
  sku                          = "Standard"
}

// Routes for K8s pods communications
resource "azurerm_route_table" "rt" {
  name                = "k8s-route-table"
  location            = "${var.loc}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_route" "rt" {
  count                  = "${var.worker_count}"

  name                   = "k8s-pod-route-${replace(var.pod_cidr_prefix, ".", "-")}-${count.index}-0-24"
  resource_group_name    = "${azurerm_resource_group.rg.name}"

  // nb: we +4 the worker_cidr_prefix.count_index because the first four IPs of a subnet are reserved by Azure
  // this is a bit hacky
  // may want to determine the address_prefix/next_hop_in_ip_address using the worker NICs instead
  route_table_name       = "${azurerm_route_table.rt.name}"
  address_prefix         = "${var.pod_cidr_prefix}.${count.index}.0/24"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "${var.worker_cidr_prefix}.${count.index + 4}"
}

resource "azurerm_subnet_route_table_association" "rt" {
  subnet_id      = "${azurerm_subnet.k8s_worker_sub.id}"
  route_table_id = "${azurerm_route_table.rt.id}"
}
