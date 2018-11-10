# Kubernetes Lab

> Self-managed Kubernetes from scratch on Azure, with Terraform and Ansible

## Acknowledgements

This is heavily based on Kelsey Hightower's _[Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)_ for GCP.

His cluster was transliterated to Azure and automated with Terraform and Ansible. Additional changes include isolating controllers and workers into distinct subnets to enforce stricter network access controls, and tweaking some of the networking decisions to theoretically scale up to 250 controllers and workers.

## Motivation and Purpose

Managed clusters from cloud providers abstract most of the underlying Kubernetes components away, and desktop-focussed solutions like Minikube are not representative of production clusters.

This was built to:

* understand how Kubernetes components fit together, from the ground up
* provide a representative playground to fiddle around with custom security scenarios, such as those that may be encountered during pentests

## Quick Use

[Create an Azure service principal account](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html) for Terraform, copy `tf/environment/secrets.tfvars.sample` to `tf/environment/secrets.tfvars`, and populate the file with your service principal details and SSH public key:

```
# tf/environment/secrets.tfvars
subscription_id         = ""
client_id               = ""
client_secret           = ""
tenant_id               = ""

vm_ssh_key = ""
```

The project uses a Makefile to call Terraform and then Ansible:

```
$ make
...
================================================================================

The Kubernetes endpoint is: https://40.81.58.6:6443/

CA cert is in: as/certs/ca/ca.pem

Admin user cert and key are in: as/certs/admin/admin(-key).pem

kubectl has been configured for the cluster

SSH:
  ssh -F as/ssh_config jumpbox
  ssh -F as/ssh_config k8s-controller-vm-0
  ssh -F as/ssh_config k8s-worker-vm-0

================================================================================
```

## Configuration

The `tf/environment/env.tfvars` contains most of the configurable details, including number of controllers and workers and respective VM sizes.

## Security

This cluster implements some good security practices:

* mutual TLS authentiction between all components
* etcd secrets encrypted at rest
* support for gVisor for untrusted payloads

> Caution: during setup some binaries are pulled from remote URLs without integrity checks, theoretically opening the installation to supply-chain attacks

While this repo should provide a secure bare cluster, it was only designed with training in mind. I do not recommend it for production use.

## Limitations and Known Issues

The Ansible is _not_ idempotent; everytime you run it, new certs will be generated and services will bounce.

There's an apparent bug with NSG-subnet associations in the `azurerm` Terraform provider that causes NSG's to disassociate from subnets when updating a terraformed environment. You'll run into this issue is you try to rebuild/update an existing cluster. ATM you'll need to re-attach the NSGs to the subnets from the CLI or portal, or build from scratch.
