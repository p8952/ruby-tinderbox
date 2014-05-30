#!/usr/bin/env bash

sudo emerge --sync --quiet
RUBIES="dev-lang/ruby:1.9 dev-lang/ruby:2.0 dev-lang/ruby:2.1 dev-java/jruby"
sudo emerge --pretend $RUBIES
if [[ $? == 1 ]]; then
	sudo emerge --autounmask-write $RUBIES
	sudo etc-update --automode -5
fi
sudo emerge --noreplace $RUBIES
