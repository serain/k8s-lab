/*
    General project settings
*/

project = "k8s-lab"
loc = "australiasoutheast"
vm_user = "kadmin"
jumpbox_cidr = "10.0.0.0/24"

/*
    Jumpbox settings
*/

jumpbox_cidr = "10.0.0.0/24"
jumpbox_vm_size = "Standard_A1"

/*
    Controllers settings
*/

// ranges for the kubernetes controllers and workers
k8s_controller_cidr = "10.240.0.0/24"
k8s_controller_vm_count = "3"
k8s_controller_vm_size = "Standard_A1"

/*
    Workers and pods settings
*/

k8s_worker_cidr = "10.240.1.0/24"
k8s_worker_vm_count = "3"
k8s_worker_vm_size = "Standard_D1_v2"
// used to set the routes for pod-pod communication
// it should be the first three bytes of the k8s_worker_cidr, without the trailing dot
k8s_worker_cidr_prefix = "10.240.1"
// range prefix for the pods
// ie: k8s-worker-vm-1 will spawn pods on the 10.200.1.0/24 range
pod_cidr_prefix = "10.200"
