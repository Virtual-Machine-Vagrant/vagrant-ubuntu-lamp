Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64" # We are running Ubuntu in this project.
  config.vm.provision :shell, path: "bootstrap.bash" # Tell Vagrant to run this script as part of the provisioning process.

  config.vm.hostname = 'ubuntu-lamp.vm'; # Force host name.
  config.landrush.enabled = true # Enable the Landrush plugin.
  config.landrush.tld = 'vm' # Set a custom TLD to use for this VM.

  config.vm.synced_folder 'htdocs/', '/vagrant-htdocs', owner: 'www-data', group: 'www-data'
end
