Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/trusty64'

  # Configure the hostname for this VM.
  config.vm.hostname = 'ubuntu-lamp.vm'; # Default value.
  if !File.dirname(File.expand_path(__FILE__)).scan(/\.vm$/i).empty?
    config.vm.hostname = File.basename(File.dirname(File.expand_path(__FILE__)));
  end

  # Mount a special `/vagrant-htdocs` directory that will be owned by `www-data`.
  config.vm.synced_folder 'htdocs/', '/vagrant-htdocs', owner: 'www-data', group: 'www-data'

  # Mount WordPress project directory.
  if File.directory? File.expand_path('~/projects/wordpress')
    config.vm.synced_folder File.expand_path('~/projects/wordpress'), '/vagrant-wordpress', mount_options: ['ro']
  end

  # Mount WordPress project directory.
  if File.directory? File.expand_path('~/projects/jaswsinc/wordpress')
    config.vm.synced_folder File.expand_path('~/projects/jaswsinc/wordpress'), '/vagrant-jaswsinc-wordpress', mount_options: ['ro']
  end

  # Mount WordPress project directory.
  if File.directory? File.expand_path('~/projects/websharks/wordpress')
    config.vm.synced_folder File.expand_path('~/projects/websharks/wordpress'), '/vagrant-websharks-wordpress', mount_options: ['ro']
  end

  # Configure DNS automaticaly?
  if Vagrant.has_plugin?('landrush')
    config.landrush.enabled = true # Enable landrush plugin.
    config.landrush.tld = 'vm' # Set landrush TLD for this VM.
    # Note: this results in `.vm` being stripped from `config.vm.hostname`.
  end

  # Configure box-specific caching.
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
  end

  # Configure resource allocations.
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--vram", "256"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
  end

  # Run script(s) as part of the provisioning process.
  config.vm.provision :shell, path: 'bootstrap.bash', run: 'always'
  config.vm.provision :shell, path: 'bootstrap-wordpress.bash', run: 'always'
end
