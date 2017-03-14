wordpress-ninja-workflow
===

# Installation

In your terminal:
```shell
$ wget https://raw.githubusercontent.com/bytelaunch/wordpress-ninja-workflow/master/wp-ninja.sh

$ chmod +x wp-ninja.sh

$ mv wp-ninja.sh /usr/local/bin/wp-ninja
```

## Usage

Using the template provided, create a configuration file for your specific WordPress settings.
```shell
# wp-ninja {config_file} {wwwroot}

$ wp-ninja site.conf public_html/
```

# Requirements

### Accounts, Licenses, Keys
This documentation assumes you have the following licenses and accounts.

* A local MySQL database setup
* Migrate DB Pro - License Key
* Migrate DB Pro - Connection Info and "Secret Key" to source website

### Software Requirements

It's assumed you have the following software installed on the destination server.

* composer - https://getcomposer.org/download/
* WP-CLI - http://wp-cli.org/#installing


# Manual Workflow

#### Step 1. Checkout Repo
```shell
# Clone Repo
# -----------
git clone https://github.com/{my}/{repo}.git .

# Get "develop" branch
# ---------------------
git checkout develop
```


#### Step 2. Download and Install WordPress Core

```shell
# Download
# ---------
wp core download --version={version.number}

# wp-config.php
# --------------
# Test db credentials and create wp-config.php
wp core config --dbname={dbname} --dbuser={dbuser} --dbpass={dbpass} --dbhost={127.0.0.1}

# Install WP
# -----------
# You can leave the placeholders intact here, since
# WP Migrate will update the database
wp core install --url='http://localhost/my-site' --title='My Site' --admin_user=admin --admin_passw
```

#### Step 3. Install plugins from WordPress Repo
```shell
wp plugin install \
    regenerate-thumbnails \
    wd-google-maps \
    simple-custom-post-order \
    wordpress-importer \
    addthis \
    custom-post-type-ui \
    simple-image-sizes \
    wordpress-seo \
    duplicate-post \
    modern-events-calendar \
    uber-login-logo \
    wp-user-avatar
```

#### Step 4. Database Import

```shell
# Install WP Migrate
# ------------------
# from composer.json -- make sure this file exists!
composer install

# Activate migration plugins
wp plugin activate wp-migrate-db-pro wp-migrate-db-pro-media-files wp-migrate-db-pro-cli

# Update License
wp migratedb setting update license {lic-ense-key-goes-here}

# fetch db from live
wp migratedb pull \
    https://www.mywaterpledge.com {pull-authorization-key} \
    --find=//www.site.com \
    --replace=//dev.site.com \
    --skip-replace-guids \
    --preserve-active-plugins \
```
