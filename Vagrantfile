# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.box_url = "https://vagrantcloud.com/ubuntu/boxes/trusty64/versions/1/providers/virtualbox.box"

  config.vm.hostname = "devbox.local"
  config.vm.network "public_network", ip: "192.168.1.17"

  # Stolen from: https://github.com/DSpace/vagrant-dspace/blob/master/Vagrantfile#L146
  # Turn on SSH forwarding (so that 'vagrant ssh' has access to your local SSH keys, and you can use your local SSH keys to access GitHub, etc.)
  config.ssh.forward_agent = true
  
  # THIS NEXT PART IS TOTAL HACK (only necessary for running Vagrant on Windows)
  # Windows currently doesn't support SSH Forwarding when running Vagrant's "Provisioning scripts" 
  # (e.g. all the "config.vm.provision" commands below). Although running "vagrant ssh" (from Windows commandline) 
  # will work for SSH Forwarding once the VM has started up, "config.vm.provision" commands in this Vagrantfile DO NOT.
  # Supposedly there's a bug in 'net-ssh' gem (used by Vagrant) which causes SSH forwarding to fail on Windows only
  # See: https://github.com/mitchellh/vagrant/issues/1735
  #      https://github.com/mitchellh/vagrant/issues/1404
  # See also underlying 'net-ssh' bug: https://github.com/net-ssh/net-ssh/issues/55
  #
  # Therefore, we have to "hack it" and manually sync our SSH keys to the Vagrant VM & copy them over to the 'root' user account
  # (as 'root' is the account that runs all Vagrant "config.vm.provision" scripts below). This all means 'root' should be able 
  # to connect to GitHub as YOU! Once this Windows bug is fixed, we should be able to just remove these lines and everything 
  # should work via the "config.ssh.forward_agent=true" setting.
  # ONLY do this hack/workaround if the local OS is Windows.
  if Vagrant::Util::Platform.windows?
    # MORE SECURE HACK. You MUST have a ~/.ssh/github_rsa (GitHub specific) SSH key to copy to VM
    # (ensures we are not just copying all your local SSH keys to a VM)
    if File.exists?(File.join(Dir.home, ".ssh", "github_rsa"))
      # Read local machine's GitHub SSH Key (~/.ssh/github_rsa)
      github_ssh_key = File.read(File.join(Dir.home, ".ssh", "github_rsa"))
      # Copy it to VM as the /root/.ssh/id_rsa key
      config.vm.provision :shell, :inline => "echo 'Windows-specific: Copying local GitHub SSH Key to VM for provisioning...' && mkdir -p /home/vagrant/.ssh && echo '#{github_ssh_key}' > /home/vagrant/.ssh/id_rsa && chmod 600 /home/vagrant/.ssh/id_rsa && chown -R vagrant:vagrant /home/vagrant/.ssh"
    else
      # Else, throw a Vagrant Error. Cannot successfully startup on Windows without a GitHub SSH Key!
      raise Vagrant::Errors::VagrantError, "\n\nERROR: GitHub SSH Key not found at ~/.ssh/github_rsa (required for git on Windows).\nYou can generate this key manually OR by installing GitHub for Windows (http://windows.github.com/)\n\n"
    end   
  end

  # Create a '/etc/sudoers.d/root_ssh_agent' file which ensures sudo keeps any SSH_AUTH_SOCK settings
  # This allows sudo commands (like "sudo ssh git@github.com") to have access to local SSH keys (via SSH Forwarding)
  # See: https://github.com/mitchellh/vagrant/issues/1303
  config.vm.provision :shell do |shell|
    shell.inline = "touch $1 && chmod 0440 $1 && echo $2 > $1"
    shell.args = %q{/etc/sudoers.d/root_ssh_agent "Defaults    env_keep += \"SSH_AUTH_SOCK\""}
  end

  # Check our system locale -- make sure it is set to UTF-8
  config.vm.provision :shell, :inline => "locale | grep 'LANG=en_US.UTF-8' > /dev/null || sudo update-locale --reset LANG=en_US.UTF-8"

  # Turn off annoying console bells/beeps in Ubuntu (only if not already turned off in /etc/inputrc)
  config.vm.provision :shell, :inline => "grep '^set bell-style none' /etc/inputrc || echo 'set bell-style none' >> /etc/inputrc"


  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'" # avoids 'stdin: is not a tty' error.


  $script = <<SCRIPT
apt-get update

echo "Install Ansible"
apt-get install -y software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get install -y ansible

echo "Install git"
apt-get install -y git

echo "Add SSH Key to known_hosts"
sudo -i -u vagrant mkdir -p /home/vagrant/.ssh
sudo -i -u vagrant ssh-keyscan -t rsa -H github.com >> /home/vagrant/.ssh/known_hosts

echo "Checkout this repo"
sudo -i -u vagrant git clone https://github.com/ScorpionResponse/devbox.git devbox

echo "Run the ansible-playbook locally"
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
