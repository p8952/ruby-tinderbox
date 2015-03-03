#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

emerge-webrsync
emerge --metadata
cp "$SCRIPT_DIR/make.conf" /etc/portage/make.conf

RUBIES="dev-lang/ruby:1.9 dev-lang/ruby:2.0 dev-lang/ruby:2.1 dev-lang/ruby:2.2"
set +e
emerge --pretend --quiet $RUBIES
if [[ $? == 1 ]]; then
       emerge --autounmask-write $RUBIES
       etc-update --automode -5
fi
set -e
emerge --noreplace --quiet $RUBIES
