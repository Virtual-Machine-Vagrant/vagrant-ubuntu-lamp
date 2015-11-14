Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/trusty64'

  # Configure the hostname for this VM.
  config.vm.hostname = 'ubuntu-lamp.vm'; # Default value.
  if !File.dirname(File.expand_path(__FILE__)).scan(/\.vm$/i).empty?
    config.vm.hostname = File.basename(File.dirname(File.expand_path(__FILE__)));
  end

  # Mount `/vagrant` as `/bootstrap`.
  config.vm.synced_folder '.', '/bootstrap'
  config.vm.synced_folder '.', '/vagrant', disabled: true

  # Mount a special `/htdocs` directory that will be owned by `www-data`.
  config.vm.synced_folder 'htdocs/', '/htdocs', owner: 'www-data', group: 'www-data'

  # Mount WordPress project directory.
  if File.directory? File.expand_path('~/projects/wordpress')
    config.vm.synced_folder File.expand_path('~/projects/wordpress'), '/wordpress'
  end

  # Mount WordPress project directory.
  if File.directory? File.expand_path('~/projects/jaswsinc/wordpress')
    config.vm.synced_folder File.expand_path('~/projects/jaswsinc/wordpress'), '/jaswsinc-wordpress'
  end

  # Mount WordPress project directory.
  if File.directory? File.expand_path('~/projects/websharks/wordpress')
    config.vm.synced_folder File.expand_path('~/projects/websharks/wordpress'), '/websharks-wordpress'
  end

  # Configure DNS automaticaly?
  if Vagrant.has_plugin?('landrush')
    config.landrush.enabled = true # Enable landrush plugin.
    config.landrush.tld = 'vm' # Set landrush TLD for this VM.
    config.landrush.upstream '8.8.8.8' # Google public DNS.
  end

  # Configure box-specific caching.
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
  end

  # Configure resource allocations.
  config.vm.provider 'virtualbox' do |vb|
    vb.customize ['modifyvm', :id, '--memory', '1024']
    vb.customize ['modifyvm', :id, '--vram', '128']
    vb.customize ['modifyvm', :id, '--cpus', '1']
  end

  # Run script(s) as part of the provisioning process.
  config.vm.provision :shell, path: 'bootstrap', run: 'always'
  config.vm.provision :shell, path: 'bootstrap-wp', run: 'always'
  if Vagrant.has_plugin?('vagrant-triggers')
    config.trigger.after [:up, :resume], :append_to_path => File.dirname(File.expand_path(__FILE__)) do
      run 'bootstrap-me'
    end
  end
end
