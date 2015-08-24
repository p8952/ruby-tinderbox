#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
[[ $(whoami) == 'root' ]] || exit 1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function ENV_SETUP() {
	if [[ ! -d $SCRIPT_DIR/ci-logs/ ]]; then
		mkdir "$SCRIPT_DIR/ci-logs"
	fi
}

function SETUP() {
	mkdir -p "$SCRIPT_DIR/overlay"
	mkdir -p "$SCRIPT_DIR/overlay/$CATEGORY/$NAME"
	cp "/usr/portage/$CATEGORY/$NAME/$NAME-$VERSION.ebuild" "$SCRIPT_DIR/overlay/$CATEGORY/$NAME"
	cp "/usr/portage/$CATEGORY/$NAME/metadata.xml" "$SCRIPT_DIR/overlay/$CATEGORY/$NAME"
}

function REPOMAN() {
	cd "$SCRIPT_DIR/overlay/$CATEGORY/$NAME"
	repoman scan || true
	repoman manifest
	repoman full > /tmp/repoman_log_current || true

	if [[ "$NEXT_TARGET" != 'nil' ]]; then
		sed -i -e "/^USE_RUBY/s/=\"/=\"$NEXT_TARGET /" "$NAME-$VERSION.ebuild"
		repoman manifest
		repoman full > /tmp/repoman_log_next || true
	fi

	LOG
}

function LOG() {
	SHA1=$(sha1sum "/usr/portage/$CATEGORY/$NAME/$NAME-$VERSION.ebuild" | awk '{print $1}')

	mkdir -p "$SCRIPT_DIR/ci-logs/$SHA1/$DATE/repomans/current"
	cp /tmp/repoman_log_current "$SCRIPT_DIR/ci-logs/$SHA1/$DATE/repomans/current/repoman_log"

	if [[ "$NEXT_TARGET" != 'nil' ]]; then
		mkdir -p "$SCRIPT_DIR/ci-logs/$SHA1/$DATE/repomans/next_target"
		cp /tmp/repoman_log_next "$SCRIPT_DIR/ci-logs/$SHA1/$DATE/repomans/next_target/repoman_log"
	fi

	chmod 755 -R "$SCRIPT_DIR/ci-logs"
}

function CLEANUP() {
	rm /tmp/repoman_log_current || true
	rm /tmp/repoman_log_next || true
	rm -r "$SCRIPT_DIR/overlay" || true
}

ENV_SETUP

DATE=$(date +%s)
PKG_ARR=($(qatom "$1"))
CATEGORY="${PKG_ARR[0]}"
NAME="${PKG_ARR[1]}"
if [[ ${PKG_ARR[3]:=foo} == 'foo' ]]; then
	VERSION="${PKG_ARR[2]}"
else
	VERSION="${PKG_ARR[2]}-${PKG_ARR[3]}"
fi

NEXT_TARGET=$2
SETUP
REPOMAN
CLEANUP
