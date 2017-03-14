#!/bin/bash
set -e

# echo $1 && exit 1 ;

RED='\033[1;31m'
GREY='\033[1;30m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
. "./$1"

cd $2


comment() {
	echo -e "${WHITE}$1${NC}"
}
do_command() {
	echo -e "${RED}→  ${GREY}$1${NC}"
	echo ""
	eval $1
}

comment
comment "# STEP 1. CHECKOUT REPO";
comment "# ======================"
do_command "git clone $git_repo ."
comment

comment
comment "# Get 'develop' branch"
comment "# ---------------------"
do_command "git checkout $git_branch"
comment


comment
comment "# STEP 2. DOWNLOAD AND INSTALL WP CORE";
comment "# ====================================="

comment
comment "# Download"
comment "# ---------"
do_command "wp core download --version=$wp_core_version"
comment


comment
comment "# wp-config.php"
comment "# --------------"
comment "# Test db credentials and create wp-config.php"
do_command "wp core config --dbname=$db_name --dbuser=$db_user --dbpass=$db_pass --dbhost=$db_host"
comment

comment
comment "# Install WP"
comment "# -----------"
comment "# You can leave the placeholders intact here, since"
comment "# WP Migrate will update the database"
do_command "wp core install --url='http://localhost/my-site' --title='My Site' --admin_user=admin --admin_password=password  --admin_email='me@example.com'"
comment


comment
comment "# STEP 3. INSTALL PLUGINS FROM WP REPO";
comment "# ====================================="

comment
do_command "wp plugin install $wp_plugins"
comment

comment
comment "# STEP 4. DATABASE IMPORT";
comment "# ========================"

comment
comment "# Install WP Migrate"
comment "# ------------------"
comment "# from composer.json -- make sure this file exists!"
do_command "composer install"
comment

comment
comment "# Activate migration plugins"
do_command "wp plugin activate wp-migrate-db-pro wp-migrate-db-pro-media-files wp-migrate-db-pro-cli"
comment

comment
comment "# Update License"
do_command "wp migratedb setting update license $migratedb_license"
comment

comment
comment "# Fetch db from source"
do_command "wp migratedb pull $migratedb_pull --find=$migratedb_find --replace=$migratedb_replace $migratedb_flags"
comment

