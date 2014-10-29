#!/usr/bin/env bash
set -o errexit
[[ $(whoami) == 'root' ]] || exit 1

function ENV_SETUP() {
	eselect news read --quiet all
	if [[ ! -d /etc/portage/env/ ]]; then
		mkdir /etc/portage/env/
	fi
	echo 'FEATURES="${FEATURES} test keepwork"' > /etc/portage/env/test

	if [[ ! -d /vagrant/logs/ ]]; then
		mkdir /vagrant/logs/
	fi
}

function SETUP () {
	cp /var/lib/portage/world /var/lib/portage/world.original
	echo "" > /etc/portage/package.accept_keywords
	echo "=dev-ruby/$RUBY_PACKAGE doc" > /etc/portage/package.use
	echo "=dev-ruby/$RUBY_PACKAGE test" > /etc/portage/package.env

	if [[ -e /usr/portage/packages/dev-ruby/$RUBY_PACKAGE.tbz2 ]]; then
		rm /usr/portage/packages/dev-ruby/$RUBY_PACKAGE.tbz2
	fi

	set +e
	emerge --pretend --quiet "=dev-ruby/$RUBY_PACKAGE"
	if [[ $? == 1 ]]; then
		emerge --autounmask-write "=dev-ruby/$RUBY_PACKAGE"
		etc-update --automode -5
	fi
	set -e
}

function EMERGE() {
	set +e
	timeout 1000 emerge --usepkg --buildpkg "=dev-ruby/$RUBY_PACKAGE"
	LOG $? dev-ruby/$RUBY_PACKAGE
	set -e
}

function LOG() {
	DATE=$(date +%s)
	mkdir -p /vagrant/logs/$RUBY_PACKAGE/$DATE
	emerge --info "=dev-ruby/$RUBY_PACKAGE" > /vagrant/logs/$RUBY_PACKAGE/$DATE/emerge-info
	emerge -pqv "=dev-ruby/$RUBY_PACKAGE" > /vagrant/logs/$RUBY_PACKAGE/$DATE/emerge-pqv
	cp /var/tmp/portage/dev-ruby/$RUBY_PACKAGE/temp/build.log /vagrant/logs/$RUBY_PACKAGE/$DATE/build.log
	cp /var/tmp/portage/dev-ruby/$RUBY_PACKAGE/temp/environment /vagrant/logs/$RUBY_PACKAGE/$DATE/environment
	if [[ $1 == 0 ]]; then
		RESULT="\e[0;32mBUILD SUCCEEDED\e[0m"
		touch /vagrant/logs/$RUBY_PACKAGE/$DATE/succeeded
	elif [[ $1 == 1 ]]; then
		RESULT="\e[0;31mBUILD FAILED\e[0m"
		touch /vagrant/logs/$RUBY_PACKAGE/$DATE/failed
	elif [[ $1 == 124 ]]; then
		RESULT="\e[0;31mBUILD TIMED OUT\e[0m"
		touch /vagrant/logs/$RUBY_PACKAGE/$DATE/timedout
	else
		RESULT="\e[0;31mBUILD UNKNOWN\e[0m"
		touch /vagrant/logs/$RUBY_PACKAGE/$DATE/unknown
	fi
	chmod 755 -R /vagrant/logs/$RUBY_PACKAGE/$DATE
}

function CLEANUP() {
	mv /var/lib/portage/world.original /var/lib/portage/world
	emerge --depclean --quiet
}

ENV_SETUP
RUBY_PACKAGES=$@
for RUBY_PACKAGE in ${RUBY_PACKAGES[@]}; do
	SETUP $RUBY_PACKAGE
	EMERGE $RUBY_PACKAGE
	CLEANUP
	echo -e "$RUBY_PACKAGE : $RESULT"
done
