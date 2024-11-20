# -*- mode: ruby -*-
# vi: set ft=ruby :

box = "boxen/ubuntu-20.04"
ver = "2024.07.24.10"
num = 2
ip = '192.168.0.10'
broad = '192.168.0.255'
port = 1003
master = "openstack"

Vagrant.configure("2") do |config|
  config.vm.define master do |c|
    c.vm.disk :disk, size: "30GB", primary: true
    c.vm.box=box
    c.vm.box_version = ver
    c.vm.provider :hyperv do |v|
      v.vmname=master
      v.cpus=4
      v.memory=4096
      v.linked_clone=true
    end

    c.vm.hostname=master
    c.vm.synced_folder ".", "/vagrant", disabled: true
    c.vm.network "forwarded_port", guest: 22, host: "#{port}0", auto_correct: true, id: "ssh"
    c.vm.provision 'shell', path: "bootstrap.sh"
  end
end