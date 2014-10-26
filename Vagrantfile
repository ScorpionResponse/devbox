# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.box_url = "https://vagrantcloud.com/ubuntu/boxes/trusty64/versions/1/providers/virtualbox.box"
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'" # avoids 'stdin: is not a tty' error.


  $script = <<SCRIPT
apt-get update

# Install Ansible
apt-get install -y software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get install -y ansible

# Install Git
apt-get install -y git

# Checkout the repo
sudo -i -u vagrant git clone https://github.com/ScorpionResponse/devbox.git devbox

# Run the site.yml configuration
cd devbox
ansible-playbook ansible/site.yml -i ansible/hosts --connection=local

SCRIPT

  config.vm.provision :shell, inline: $script

  config.vm.provider "virtualbox" do |v|
    v.name = "devbox"
    v.memory = 1024
    v.cpus = 2
  end

end
