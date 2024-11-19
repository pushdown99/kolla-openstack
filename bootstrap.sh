#!/bin/bash
#
# https://medium.com/btech-engineering/install-openstack-aio-with-kolla-ansible-in-ubuntu-2b98fc9de4ce

growpart /dev/sda 3
lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
resize2fs /dev/ubuntu-vg/ubuntu-lv

apt-get update
apt install -y python3-dev libffi-dev gcc libssl-dev python3-venv python3-pip net-tools
python3 -m venv venv
source venv/bin/activate

pip install -U pip
pip install docker
pip install 'ansible>=4,<6'
pip install kolla-ansible==14.2.0

chown -R $USER:$USER venv

mkdir /etc/kolla
cp -r venv/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp -r venv/share/kolla-ansible/ansible/inventory/* .
mv /etc/kolla/globals.yml /etc/kolla/globals.yml.bak

cat << EOF | sudo tee /etc/kolla/globals.yml
kolla_base_distro: "ubuntu"
kolla_install_type: "source"
openstack_release: "2024.2"

kolla_internal_vip_address: "172.168.12.100"
network_interface: "eth1"
neutron_external_interface: "eth0"
neutron_plugin_agent: "openvswitch"
api_interface: "eth2"
enable_keystone: "yes"
enable_neutron_trunk: "yes"

enable_cinder: "yes"
enable_cinder_backup: "no"
enable_cinder_backend_lvm: "yes"
enable_horizon: "yes"
enable_neutron_provider_networks: "yes"
EOF

chown -R $USER:$USER /etc/kolla

mkdir /etc/ansible
cat << EOF | sudo tee /etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
pipelining=True
forks=100
EOF

chown -R $USER:$USER /etc/ansible

kolla-genpwd


sed -i 's/yoga/2023.2/g' venv/share/kolla-ansible/requirements.yml
