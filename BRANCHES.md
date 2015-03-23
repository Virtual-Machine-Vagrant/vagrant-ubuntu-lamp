## Branched Variations

### Master Branch (i.e., `$ git checkout master`)

This is the default branch and it is a full LAMP stack that you can customize further.

### WordPress Branch (i.e., `$git checkout wordpress`)

This is based on the `master` branch, but with a few WordPress-specific enhancements.

- The latest version of WordPress is installed automatically.
- A `/wp-config.php` file is generated automatically.
- If you have `~/Projects/wordpress/plugins` in your local home directory and it contains WordPress plugin repositories, these are mounted in a readonly state on the VM; and then symlinked automatically into the `htdocs/wp-content/plugins` directory. This allows you to test your own WordPress plugins from the VM; i.e., if you make changes locally, the VM knows about those changes. Instant sync!
- If you have `~/Projects/wordpress/themes` in your local home directory, these are symlinked in the same way.

After you run `$ vagrant up`, visit `http://ubuntu-lamp-wordpress.vm` and follow the instructions to finalize the installation of WordPress.

---

### Default Host Changes Based on Branch

The default hostname is: `http://ubuntu-lamp.vm`

_**Note:** If you use something other than the `master` branch in this repo, the default hostname will be different. It will include the branch name; e.g., `http://ubuntu-lamp-wordpress.vm` if you are running the `wordpress` branch._