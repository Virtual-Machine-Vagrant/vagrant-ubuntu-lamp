## VirtualBox + Vagrant + Landrush; running Ubuntu w/ Apache, MySQL, PHP, and WordPress.

![](http://cdn.websharks-inc.com/jaswsinc/uploads/2015/03/os-x-vagrant-virtualbox.png)

---

### Installation Instructions

#### Step 1: Satisfy Software Requirements

You need to have VirtualBox, Vagrant, and Landrush installed.

```bash
$ brew cask install virtualbox
$ brew cask install vagrant
$ vagrant plugin install landrush
$ vagrant plugin install vagrant-cachier # Suggested (optional).
$ vagrant plugin install vagrant-triggers # Suggested (optional).
```

You need to install the `ubuntu/trusty64` Box.

```bash
$ vagrant box add ubuntu/trusty64
```

#### Step 2: Clone GitHub Repo (Ubuntu LAMP Stack)

```bash
$ mkdir ~/VMs && cd ~/VMs
$ git clone https://github.com/jaswsinc/vagrant-ubuntu-lamp my.vm
```

_Note that `my.vm` is what we clone into. This becomes your domain name. Change it if you like. Must end with `.vm` please._

#### Step 3: Vagrant Up!

```bash
$ cd ~/VMs/my.vm
$ vagrant up # This may take a few.
```

#### Step 4: Confirm it is Working!

- Open <http://my.vm>. You should see a WordPress installation page.
- Open <https://my.vm>. You should get an SSL security warning. Please bypass this self-signed certificate warning and proceed. You should again see the WordPress installation page. SSL is working as expected!

##### The URL <http://my.vm> is not working?

Try flushing your DNS cache. Each time you `vagrant up`, a new IP is generated automatically that is mapped to the `my.vm` hostname. If you are working with multiple VMs, you might need to flush your DNS cache to make sure your system is mapping `my.vm` to the correct IP address. See: <http://jas.xyz/1fmAa4P> for instructions on a Mac.

---

### Additional Steps (All Optional)

#### Step 5: Add Files to: `~/VMs/my.vm/htdocs/`

The is the web root. The latest version of WordPress will already be installed. However, you can add any additional application files that you'd like. e.g., phpBB, Drupal, Joomla, whatever you like. It's probably a good idea to put anything new inside a sub-directory of its own; e.g., `~/VMs/my.vm/htdocs/phpBB`

#### Step 6: Understanding Environment Variables

This stack comes preconfigured with a MySQL database and environment variables you can use in any PHP config. files.

- `$_SERVER['MYSQL_DB_HOST']` This is the database host name. Defaults to `localhost`. Port is `3306` (default port).
- `$_SERVER['MYSQL_DB_NAME']` This is the database name. Defaults to `vagrant`.
- `$_SERVER['MYSQL_DB_USER']` This is the database username. Defaults to `vagrant`.
- `$_SERVER['MYSQL_DB_PASSWORD']` This is the database password. Defaults to `vagrant`.

#### Step 7: Learn to Use the Tools That I've Bundled

A username/password is required to access each of these tools. It is always the same thing.

- Username: `vagrant` Password: `vagrant`

Available Tools (Using Any of These is Optional):

- <https://my.vm/tools/pma> PhpMyAdmin  
  DB name: `vagrant`, DB username: `vagrant`, DB password: `vagrant`
- <https://my.vm/tools/opcache.php> PHP OPCache extension status dump.
- <https://my.vm/tools/info.php> PHP info (i.e., `phpinfo()`) page.
- <https://my.vm/tools/fpm-status.php> PHP-FPM status page.
- <https://my.vm/tools/apache-status/> Apache status page.
- <https://my.vm/tools/apache-info/> Apache info page.

#### Step 8: Tear it Down and Customize

```bash
$ cd ~/VMs/my.vm
$ vagrant destroy # Might take a sec.
```

In the project directory you'll find `bootstrap`, `bootstrap-wp`, etc. Each of these scripts are run as the `root` user during `vagrant up`. Thus, you can install software and configure anything you like in these scripts. At the top of `bootstrap` there are some configurable parameters that you can tune-in if you like. You may also want to tweak the `Vagrantfile` for the project.

```bash
$ vagrant up # Bring it back up.
```

---

### Domain Name Tips & Tricks

#### Creating a Second VM w/ a Different Domain Name

```bash
$ git clone https://github.com/jaswsinc/vagrant-ubuntu-lamp my-second.vm
$ cd my-second.vm && vagrant up # Now visit: `http://my-second.vm`
```

#### Understanding Domain Name Mapping

The URL which leads to your VM is based on the name of the directory that you cloned the repo into; e.g., `my.vm` or `my-second.vm` in the above examples. However, the directory that you clone into MUST end with `.vm` for this to work as expected. If the directory you cloned into doesn't end with `.vm`, the default domain name will be `http://ubuntu-lamp.vm`. You can change this hard-coded default by editing `config.vm.hostname` in `Vagrantfile`.

In either case, the domain name is also wildcarded; i.e., `my.vm`, `www.my.vm`, `wordpress.my.vm` all map to the exact same location: `~/VMs/my.vm/htdocs/`. This is helpful when testing WordPress Multisite Networks, because you can easily setup a sub-domain network, or even an MU domain mapping plugin.

---

### Testing WordPress Themes/Plugins Easily!

See `/Vagrantfile` where you will find this section already implemented.
_~ See also: `/bootstrap-wp`_

```ruby
if File.directory? File.expand_path('~/projects/wordpress')
  config.vm.synced_folder File.expand_path('~/projects/wordpress'), '/vagrant-wordpress'
end
if File.directory? File.expand_path('~/projects/jaswsinc/wordpress')
  config.vm.synced_folder File.expand_path('~/projects/jaswsinc/wordpress'), '/vagrant-jaswsinc-wordpress'
end
if File.directory? File.expand_path('~/projects/websharks/wordpress')
  config.vm.synced_folder File.expand_path('~/projects/websharks/wordpress'), '/vagrant-websharks-wordpress'
end
```

#### ↑ What is happening here w/ these WordPress directories?

The `Vagrantfile` is automatically mounting drives on your VM that are sourced by your local `~/projects` directory (if you have one). Thus, if you have your WordPress themes/plugins in `~/projects/wordpress` (i.e., in your local filesystem), it will be mounted on the VM automatically, as `/vagrant-wordpress`.

In the `bootstrap-wp` file, we iterate `/vagrant-wordpress` and build symlinks for each of your themes/plugins automatically. This means that when you log into your WordPress Dashboard (<http://my.vm/wp-admin/>), you will have all of your themes/plugins available for testing. If you make edits locally in your favorite editor, they are updated in real-time on the VM. Very cool!

The additional mounts (i.e., `~/projects/jaswsinc/wordpress` and `~/projects/websharks/wordpress`) are simply alternate locations that I use personally. Remove them if you like. See: `Vagrantfile` and `bootstrap-wp` to remove in both places. You don't really _need_ to remove them though, because if these locations don't exist on your system they simply will not be mounted. In fact, you might consider leaving them, and just alter the paths to reflect your own personal preference—or for future implementation.

#### The default WordPress mapping looks like this:

- `~/projects/wordpress` on your local system.
  - Is mounted on the VM, as: `/vagrant-wordpress`
- Then (on the VM) the `boostrap-wordpress.bash` script symlinks each theme/plugin into:
  - `/vagrant-htdocs/wp-content/[themes|plugins]` appropriately.

#### What directory structure do I need exactly?

Inside `~/projects/wordpress` you need to have two sub-directories. One for themes and another for plugins.

- `~/projects/wordpress/themes` (put WP themes in this directory; e.g., `my-theme`)
- `~/projects/wordpress/plugins` (put WP plugins here; e.g., `my-plugin`)

Now, whenever you `$ vagrant up`, your local copy of `~/projects/wordpress/themes/my-theme` becomes `/vagrant-htdocs/wp-content/themes/my-theme` on the VM. Your local copy of `~/projects/wordpress/plugins/my-plugin` becomes `/vagrant-htdocs/wp-content/plugins/my-plugin` on the VM ... and so on... for each theme/plugin sub-directory, and for each of the three possible mounts listed above. This all happens automatically if you followed the instructions correctly.
