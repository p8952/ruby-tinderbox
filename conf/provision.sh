#!/usr/bin/env bash
set -o errexit
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo emerge-webrsync

if [[ -f $SCRIPT_DIR/make.conf ]]; then
	sudo cp $SCRIPT_DIR/make.conf /etc/portage/make.conf
else
	sudo cp /vagrant/conf/make.conf /etc/portage/make.conf
fi

RUBIES="dev-lang/ruby:1.9 dev-lang/ruby:2.0 dev-lang/ruby:2.1"
set +e
sudo emerge --pretend --quiet $RUBIES
if [[ $? == 1 ]]; then
       sudo emerge --autounmask-write $RUBIES
       sudo etc-update --automode -5
fi
set -e
sudo emerge --noreplace --quiet $RUBIES
