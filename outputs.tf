output "wireguard_flavor" {
    value = data.huaweicloud_compute_flavors.wireguard-node-flavor
}

output "ceph-flavor" {
    value = data.huaweicloud_compute_flavors.ceph-node-flavor
}

output "ubuntu-img" {
    value = data.huaweicloud_images_images.ubuntu
}