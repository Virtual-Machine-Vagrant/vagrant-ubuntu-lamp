Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64" # We are running Ubuntu in this project.
  config.vm.provision :shell, path: "bootstrap.bash" # Tell Vagrant to run this script as part of the provisioning process.
  config.vm.provision :shell, path: "bootstrap-wordpress.bash" # Tell Vagrant to run this script also.

  config.landrush.enabled = true # Enable the Landrush plugin.
  config.vm.hostname = 'ubuntu-lamp-wordpress.vm'; # Force host name.
  config.landrush.tld = 'vm' # Set a matching custom TLD to use for this VM.

  config.vm.synced_folder 'htdocs/', '/vagrant-htdocs', owner: 'www-data', group: 'www-data'
  # ↑ Mount a special `/vagrant-htdocs` directory that will be owned by Apache.

  if !File.dirname(__FILE__).scan(/\.vm$/i).empty? # Current project directory ends with a `.vm` suffix?
    # If your project directory has `.vm` suffix, the hostname is forced to the directory basename.
    config.vm.hostname = File.basename(File.dirname(__FILE__)); # Directory basename.
    config.landrush.tld = 'vm' # Set a matching TLD.
  end
  if File.directory? File.expand_path('~/projects/wordpress') # Mount WordPress projects directory if it exists.
    config.vm.synced_folder File.expand_path('~/projects/wordpress'), '/vagrant-wordpress', mount_options: ['ro']
  end
end
