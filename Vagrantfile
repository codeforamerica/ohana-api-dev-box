# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "hashicorp/precise32"
  config.vm.hostname = "ohana-api-dev-box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 8080 on the guest machine.
  config.vm.network :forwarded_port, guest: 8080, host: 8080
  config.vm.network :forwarded_port, guest: 4000, host: 4000

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file default.pp in the manifests_path directory.
  #
  config.vm.provision :shell, path: 'bootstrap.sh', keep_color: true

  # Uncomment line 28 to use rsync. If you're on Windows, read the
  # Wiki for rsync installation instructions:
  # https://github.com/codeforamerica/ohana-api-dev-box/wiki/
  # config.vm.synced_folder '.', '/vagrant', type: 'rsync', rsync__exclude: '.git/'
end
