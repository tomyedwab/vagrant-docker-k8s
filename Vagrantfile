# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"

  # Give us ample disk space
  config.vm.disk :disk, size: "100GB", primary: true

  # Forward Docker port to host
  config.vm.network "forwarded_port", guest: 2375, host: 2375

  # Forward Kubernetes port to host
  config.vm.network "forwarded_port", guest: 16443, host: 16443

  # Forward microk8s private Docker registry to host
  config.vm.network "forwarded_port", guest: 32000, host: 32000

  config.vm.provider "virtualbox" do |vb|
    # Uncomment to display the VirtualBox GUI when booting the machine
    #vb.gui = true
 
    # Customize the amount of memory on the VM:
    vb.memory = "8192"

    # Don't waste effort checking for guest additions
    vb.check_guest_additions = false
  end
  #

  # Provision with a shell script.
  config.vm.provision "shell", path: "provision.bash"
end
