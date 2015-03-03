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
	echo $? > /tmp/repoman_result_current

	sed -i -e "/^USE_RUBY/s/$CURR_TARGET/$CURR_TARGET $NEXT_TARGET/" "$NAME-$VERSION.ebuild"
	repoman manifest
	repoman full > /tmp/repoman_log_next || true
	echo $? > /tmp/repoman_result_next

	LOG
}

function LOG() {
	DATE=$(date +%s)
	SHA1=$(sha1sum "/usr/portage/$CATEGORY/$NAME/$NAME-$VERSION.ebuild" | awk '{print $1}')
	mkdir -p "$SCRIPT_DIR/ci-logs/$SHA1/current_target/repomans/$DATE"
	mkdir -p "$SCRIPT_DIR/ci-logs/$SHA1/next_target/repomans/$DATE"

	cp /tmp/repoman_log_current "$SCRIPT_DIR/ci-logs/$SHA1/current_target/repomans/$DATE/repoman_log"
	cp /tmp/repoman_result_current "$SCRIPT_DIR/ci-logs/$SHA1/current_target/repomans/$DATE/repoman_result"
	cp /tmp/repoman_log_next "$SCRIPT_DIR/ci-logs/$SHA1/next_target/repomans/$DATE/repoman_log"
	cp /tmp/repoman_result_next "$SCRIPT_DIR/ci-logs/$SHA1/next_target/repomans/$DATE/repoman_result"

	chmod 755 -R "$SCRIPT_DIR/ci-logs"
}

function CLEANUP() {
	rm /tmp/repoman_log_current
	rm /tmp/repoman_result_current
	rm /tmp/repoman_log_next
	rm /tmp/repoman_result_next
	rm -r "$SCRIPT_DIR/overlay"
}

ENV_SETUP

PKG_ARR=($(qatom $1))
CATEGORY="${PKG_ARR[0]}"
NAME="${PKG_ARR[1]}"
if [[ ${PKG_ARR[3]:=foo} == 'foo' ]]; then
	VERSION="${PKG_ARR[2]}"
else
	VERSION="${PKG_ARR[2]}-${PKG_ARR[3]}"
fi

PACKAGE=$1
CURR_TARGET=$2
NEXT_TARGET=$3
SETUP
REPOMAN
CLEANUP
