#!/bin/bash
set -e

# echo $1 && exit 1 ;

RED='\033[1;31m'
GREY='\033[1;30m'
GREEN='\033[92m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BLINK='\033[5m'
NORMAL='\033[25m'

PR_COM_ERR=0
PR_FS_ERR=0



comment() {
	echo -e "${WHITE}$1${NC}"
}
error() {
	echo -e "${RED}(error)${NC} $1"
	echo ""
}
do_command() {
	echo -e "${RED}→  ${GREY}$1${NC}"
	echo ""
	eval $1
}

check_command() {
	if type "$1" &> /dev/null ; then
		echo -e "    [${GREEN}✓${NC}] Checking \`$1\`. Installed. "
	else
		echo -e "    [${RED}x${NC}] Checking \`$1\`. Not found ${RED}!!!${NC} - Get it at $2"
		PR_COM_ERR=1
	fi
}

check_fs() {
	if [ $1 == "file" ] ; then
			if [ -f $2 ] ; then
				echo -e "    [${GREEN}✓${NC}] $3\`$2\` -- Found."
			else
				echo -e "    [${RED}x${NC}] $3\`$2\` -- Not Found ${RED}!!!${NC}"
				PR_FS_ERR=1
			fi
	else
			if [ -d $2 ] ; then
				echo -e "    [${GREEN}✓${NC}] $3\`$2\` -- Found."
			else
				echo -e "    [${RED}x${NC}] $3\`$2\` -- Not Fosund ${RED}!!!${NC}"
				PR_FS_ERR=1
			fi
	fi
}
check_file() {
	check_fs "file" $1 $2
}

check_dir() {
	check_fs "dir" $1 $2
}

check_abort() {
	if [ $1 -eq 1 ] ; then
		echo -e "\n${RED}Aborting...${NC}\n" && exit 1
	else
		echo -e "\n${GREEN}Passed.${NC}\n"
	fi
}


test_file() {
	[ -f $1 ] &> /dev/null
}

comment
comment "# TEST PRE-REQUISITES"
comment "# ===================="
comment

comment
comment "# Testing availability of 3rd party applications"
comment "# -----------------------------------------------"
comment

check_command git "https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"
check_command composer "https://getcomposer.org/download/"
check_command wp "http://wp-cli.org/"

check_abort $PR_COM_ERR

comment
comment "# Testing config file and destination directory"
comment "# ----------------------------------------------"
comment

check_file $1 "Ninja config file: "
check_dir $2 $(printf 'Checking settings file: %s' "$2")

check_abort $PR_FS_ERR

. "./$1"

cd $2

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
