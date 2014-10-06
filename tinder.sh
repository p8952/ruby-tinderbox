#!/usr/bin/env bash
[[ $(whoami) == 'root' ]] || exit 1

function ENV_SETUP() {
	if [[ ! -d /etc/portage/env/ ]]; then
		mkdir /etc/portage/env/
	fi
	echo 'FEATURES="${FEATURES} test"' > /etc/portage/env/test

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

	emerge --pretend "=dev-ruby/$RUBY_PACKAGE"
	if [[ $? == 1 ]]; then
		emerge --autounmask-write "=dev-ruby/$RUBY_PACKAGE"
		etc-update --automode -5
	fi
}

function EMERGE() {
	emerge --usepkg --buildpkg "=dev-ruby/$RUBY_PACKAGE"
	if [[ $? == 1 ]]; then
		LOG dev-ruby/$RUBY_PACKAGE
	fi
}

function LOG() {
	DATE=$(date +%s)
	mkdir -p /vagrant/logs/$RUBY_PACKAGE/$DATE
	emerge --info "=dev-ruby/$RUBY_PACKAGE" > /vagrant/logs/$RUBY_PACKAGE/$DATE/emerge-info
	emerge -pqv "=dev-ruby/$RUBY_PACKAGE" > /vagrant/logs/$RUBY_PACKAGE/$DATE/emerge-pqv
	cp /var/tmp/portage/dev-ruby/$RUBY_PACKAGE/temp/build.log /vagrant/logs/$RUBY_PACKAGE/$DATE/build.log
	cp /var/tmp/portage/dev-ruby/$RUBY_PACKAGE/temp/environment /vagrant/logs/$RUBY_PACKAGE/$DATE/environment
}

function CLEANUP() {
	mv /var/lib/portage/world.original /var/lib/portage/world
	emerge --depclean
}

ENV_SETUP
RUBY_PACKAGES=$@
for RUBY_PACKAGE in ${RUBY_PACKAGES[@]}; do
	SETUP $RUBY_PACKAGE
	EMERGE $RUBY_PACKAGE
	CLEANUP
done
