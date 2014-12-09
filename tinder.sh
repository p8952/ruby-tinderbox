#!/usr/bin/env bash
set -o errexit
[[ $(whoami) == 'root' ]] || exit 1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function ENV_SETUP() {
	eselect news read --quiet all
	if [[ ! -d /etc/portage/env/ ]]; then
		mkdir /etc/portage/env/
	fi
	echo 'FEATURES="${FEATURES} test keepwork"' > /etc/portage/env/test

	if [[ ! -d $SCRIPT_DIR/ci-logs/ ]]; then
		mkdir $SCRIPT_DIR/ci-logs/
	fi
}

function SETUP () {
	cp /var/lib/portage/world /var/lib/portage/world.original
	echo "" > /etc/portage/package.accept_keywords
	echo "=$PACKAGE doc" > /etc/portage/package.use
	echo "=$PACKAGE test" > /etc/portage/package.env

	if [[ -e /usr/portage/packages/$PACKAGE.tbz2 ]]; then
		rm /usr/portage/packages/$PACKAGE.tbz2
	fi

	set +e
	emerge --pretend --quiet "=$PACKAGE"
	if [[ $? == 1 ]]; then
		emerge --autounmask-write "=$PACKAGE"
		etc-update --automode -5
	fi
	set -e
}

function EMERGE() {
	set +e
	timeout 1000 emerge --usepkg --buildpkg "=$PACKAGE"
	LOG $? $PACKAGE
	set -e
}

function LOG() {
	DATE=$(date +%s)
	mkdir -p $SCRIPT_DIR/ci-logs/$PACKAGE/$DATE
	emerge --info "=$PACKAGE" > $SCRIPT_DIR/ci-logs/$PACKAGE/$DATE/emerge-info
	emerge -pqv "=$PACKAGE" > $SCRIPT_DIR/ci-logs/$PACKAGE/$DATE/emerge-pqv
	cp /var/tmp/portage/$PACKAGE/temp/build.log $SCRIPT_DIR/ci-logs/$PACKAGE/$DATE/build.log
	cp /var/tmp/portage/$PACKAGE/temp/environment $SCRIPT_DIR/ci-logs/$PACKAGE/$DATE/environment
	if [[ $1 == 0 ]]; then
		RESULT="\e[0;32mBUILD SUCCEEDED\e[0m"
		touch $SCRIPT_DIR/ci-logs/$PACKAGE/$DATE/succeeded
	elif [[ $1 == 1 ]]; then
		RESULT="\e[0;31mBUILD FAILED\e[0m"
		touch $SCRIPT_DIR/ci-logs/$PACKAGE/$DATE/failed
	elif [[ $1 == 124 ]]; then
		RESULT="\e[0;31mBUILD TIMED OUT\e[0m"
		touch $SCRIPT_DIR/ci-logs/$PACKAGE/$DATE/timedout
	else
		RESULT="\e[0;31mBUILD UNKNOWN\e[0m"
		touch $SCRIPT_DIR/ci-logs/$PACKAGE/$DATE/unknown
	fi
	chmod 755 -R $SCRIPT_DIR/ci-logs/$PACKAGE/$DATE
}

function CLEANUP() {
	mv /var/lib/portage/world.original /var/lib/portage/world
	emerge --depclean --quiet
	rm -r /var/tmp/portage/* || true
}

ENV_SETUP
PACKAGES=$@
for PACKAGE in ${PACKAGES[@]}; do
	SETUP $PACKAGE
	EMERGE $PACKAGE
	CLEANUP
	echo -e "$PACKAGE : $RESULT"
done
