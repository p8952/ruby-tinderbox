#!/usr/bin/env bash
set -o errexit

sudo cp /vagrant/conf/make.conf /etc/portage/make.conf

RUBIES="dev-lang/ruby:1.9 dev-lang/ruby:2.0 dev-lang/ruby:2.1"
sudo emerge --pretend --quiet $RUBIES
if [[ $? == 1 ]]; then
       sudo emerge --autounmask-write $RUBIES
       sudo etc-update --automode -5
fi
sudo emerge --noreplace --quiet $RUBIES
