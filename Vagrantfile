# -*- mode: ruby -*-
# vi: set ft=ruby :

$script_cmder = <<-SCRIPT
choco install -y --force 7zip 7zip.install
choco install -y --force cmder
SCRIPT

$script_cmderdev = <<-SCRIPT
choco install -y --force 7zip 7zip.install
$env:path = "$env:path;c:\\tools\\cmder\\vendor\\git-for-windows\\cmd"
c:
cd \\Users\\Vagrant
git clone https://github.com/cmderdev/cmder cmderdev
TAKEOWN /F c:\\Users\\vagrant\\cmderdev /R /D y /s localhost /u vagrant /p vagrant
cd cmderdev
git remote add upstream  https://github.com/cmderdev/cmder
git pull upstream master

# cmd.exe "/K" '"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Auxiliary\\Build\\vcvars64.bat" && powershell -command "& ''c:\\Users\\Vagrant\\cmderdev\\scripts\\build.ps1'' -verbose -compile" && exit'
# copy c:\\Users\\Vagrant\\cmderdev\\launcher\\x64\\release\\cmder.exe c:\\Users\\Vagrant\\cmderdev
SCRIPT


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.

  # config.vm.box = "ubuntu/jammy64"

  config.vm.define "ubuntu-22" do |ubuntu|
    ubuntu.vm.box = "ubuntu/jammy64"
    ubuntu.vm.network "public_network", bridge: 'wlan0', :adapter=>2 , type: "dhcp"

    # ubuntu-22.vm.network :private_network, ip: "192.168.56.101"

    ubuntu.vm.provider :virtualbox do |v|
      # v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--name", "ubuntu-22"]
      v.customize ["modifyvm", :id, "--graphicscontroller", "vboxsvga"]
      v.customize ["modifyvm", :id, "--memory", 4096]
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      v.customize ["setextradata", :id, "GUI/ScaleFactor", "1.75"]
    end
  end

  config.vm.define "fedora-40" do |fedora|
    fedora.vm.box = "fedora/40-cloud-base"
    fedora.vm.network "public_network", bridge: 'wlan0', :adapter=>2 , type: "dhcp"

    fedora.vm.provider :virtualbox do |v|
      # v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--name", "fedora-40"]
      v.customize ["modifyvm", :id, "--graphicscontroller", "vboxsvga"]
      v.customize ["modifyvm", :id, "--memory", 4096]
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      v.customize ["setextradata", :id, "gui/scalefactor", "1.75"]
    end
  end

  config.vm.define "cmderdev-11" do |cmderdev|
    cmderdev.vm.box = "cmderdev-11-amd64"
    # cmderdev.vm.box_version = "0.0.0"
    # cmderdev.vm.network "public_network", bridge: 'wlan0', :adapter=>2 , type: "dhcp"

    cmderdev.vm.provider "vmware_desktop" do |v|
      v.gui = true
      # config.vm.network "public_network", bridge: 'wlan1', :adapter=>2 , type: "dhcp"
      # config.vm.network "public_network", adapter: 0, auto_config: false
      config.vm.network "public_network"
    end

    # cmderdev.vm.provision "shell", inline: $script_cmder
    cmderdev.vm.provision "shell", inline: $script_cmderdev
  end
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Disable the default share of the current code directory. Doing this
  # provides improved isolation between the vagrant box and your host
  # by making sure your Vagrantfile isn't accessible to the vagrant box.
  # If you use this you may want to enable additional shared subfolders as
  # shown above.
  # config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
