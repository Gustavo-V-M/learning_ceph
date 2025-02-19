resource "huaweicloud_vpc" "ceph-vpc" {
  name = "ceph-vpc"
  cidr = "192.168.0.0/16"
}

resource "huaweicloud_vpc_subnet" "ceph-subnet" {
  name = "ceph-subnet"
  cidr = "192.168.0.0/24"
  gateway_ip = "192.168.0.1"
  vpc_id = huaweicloud_vpc.ceph-vpc.id
}

resource "huaweicloud_vpc_subnet" "wireguard-subnet" {
  name = "wireguard-subnet"
  cidr = "192.168.1.0/24"
  gateway_ip = "192.168.1.1"
  vpc_id = huaweicloud_vpc.ceph-vpc.id
}

data "huaweicloud_compute_flavors" "ceph-node-flavor" {
    availability_zone = data.huaweicloud_availability_zones.sp_azs.names[0]
    performance_type = "normal"
    cpu_core_count = 2
    memory_size = 4
}

data "huaweicloud_compute_flavors" "wireguard-node-flavor" {
    availability_zone = data.huaweicloud_availability_zones.sp_azs.names[0]
    performance_type = "normal"
    cpu_core_count = 1
    memory_size = 1
}

data "huaweicloud_images_images" "rockylinux" {
    name = "Rocky Linux 8.8 64bit"
}

data "huaweicloud_images_images" "ubuntu" {
    name = "Ubuntu 22.04 server 64bit"
}

resource "huaweicloud_compute_instance" "wireguard-server" {
  name = "wireguard-server"
  image_id = data.huaweicloud_images_images.ubuntu.id 
  flavor_id = data.huaweicloud_compute_flavors.wireguard-node-flavor.flavors[0].id 
  security_group_ids = [ huaweicloud_networking_secgroup.sg_wireguard.id ]
  availability_zone = data.huaweicloud_availability_zones.sp_azs.names[0]

  network {
    uuid = huaweicloud_vpc_subnet.wireguard-subnet.id 
  }

  private_key = huaweicloud_kps_keypair.wireguard_keypair.private_key
  key_pair = huaweicloud_kps_keypair.wireguard_keypair.id
}

resource "huaweicloud_networking_secgroup" "sg_wireguard" {
  name        = "sg-wireguard"
  description = "Security Group for Wireguard"
}

resource "huaweicloud_networking_secgroup_rule" "sg_wireguard_rule_udp" {
  security_group_id = huaweicloud_networking_secgroup.sg_wireguard.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  ports             = "51820"
}

resource "huaweicloud_networking_secgroup_rule" "sg_wireguard_rule_ssh" {
  security_group_id = huaweicloud_networking_secgroup.sg_wireguard.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = "22"
}

resource "huaweicloud_kps_keypair" "wireguard_keypair" {
  name     = "wireguard-keypair"
  key_file = var.wireguard_keypair_path
}

variable "wireguard_keypair_path" {
  type = string
}