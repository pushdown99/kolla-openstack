#!/bin/bash
#
# https://medium.com/btech-engineering/install-openstack-aio-with-kolla-ansible-in-ubuntu-2b98fc9de4ce


#lvrename /dev/ubuntu-vg/ubuntu-lv /dev/ubuntu-vg/ubuntu-lv

growpart /dev/sda 3
pvresize /dev/sda3
lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv -r

#resize2fs /dev/ubuntu-vg/ubuntu-lv

ipaddr=`ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`
sed -i '/openstack/d' /etc/hosts
echo ${ipaddr} ' openstack' >> /etc/hosts

apt-get update
apt install -y python3-dev libffi-dev gcc libssl-dev python3-venv python3-pip net-tools
apt install -y --reinstall ca-certificates
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

num=`ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 | cut -d\. -f4`
num1=$(($num+1))
num2=$(($num+2))

ip1="${ipaddr//$num/$num1}"
ip2="${ipaddr//$num/$num2}"

cat << EOF | sudo tee /etc/kolla/globals.yml
kolla_base_distro: "ubuntu"
kolla_install_type: "source"
openstack_release: "yoga"

kolla_internal_vip_address: "$ip1"
kolla_external_vip_address: "$ip2"
network_interface: "eth0"
neutron_external_interface: "eth0"
neutron_plugin_agent: "openvswitch"
api_interface: "eth0"
enable_keystone: "yes"
enable_neutron_trunk: "yes"

enable_cinder: "yes"
enable_cinder_backup: "no"
enable_cinder_backend_lvm: "yes"
enable_horizon: "yes"
enable_neutron_provider_networks: "yes"
EOF

mkdir /etc/ansible
cat << EOF | sudo tee /etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
deprecation_warnings=False
pipelining=True
forks=100
EOF

sed -i 's/stable\/yoga/unmaintained\/yoga/g' venv/share/kolla-ansible/requirements.yml

# https://bugs.launchpad.net/kolla-ansible/+bug/2015497
sed -i 's/set -o pipefail &&/set -o pipefail && sleep 10 &&/g' venv/share/kolla-ansible/ansible/roles/nova-cell/handlers/main.yml
sed -i 's/libvirt_enable_sasl: true/libvirt_enable_sasl: false/g' venv/share/kolla-ansible/ansible/roles/nova-cell/defaults/main.yml

kolla-genpwd

chown -R $USER:$USER venv
chown -R $USER:$USER /etc/kolla
chown -R $USER:$USER /etc/ansible

vgrename ubuntu-vg cinder-volumes

echo "Run : . venv/bin/activate"
#source venv/bin/activate
#ansible -i all-in-one all -m ping 
#kolla-ansible install-deps

#apt install --reinstall ca-certificates

#kolla-ansible -i all-in-one bootstrap-servers
#kolla-ansible -i all-in-one prechecks
#kolla-ansible -i all-in-one deploy
#kolla-ansible -i all-in-one post-deploy 