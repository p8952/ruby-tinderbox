#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DIST_MIRROR="http://mirror.bytemark.co.uk/gentoo/"
LATEST_STAGE3=$(curl -s $DIST_MIRROR/releases/amd64/autobuilds/latest-stage3-amd64.txt | tail -1 | awk '{print $1}')
STAGE3_URI="$DIST_MIRROR/releases/amd64/autobuilds/$LATEST_STAGE3"

if [[ ! -f "$SCRIPT_DIR/../cache/stage3-amd64.tar.bz2" ]]; then
	curl -o "$SCRIPT_DIR/../cache/stage3-amd64.tar.bz2" $STAGE3_URI
fi
