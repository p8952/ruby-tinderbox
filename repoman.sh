#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
[[ $(whoami) == 'root' ]] || exit 1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function ENV_SETUP() {
	rm -r "$SCRIPT_DIR/.git" || true
	mkdir -p "$SCRIPT_DIR/overlay"
	mkdir -p "$SCRIPT_DIR/repo-logs"
}

function SETUP() {
	mkdir -p "$SCRIPT_DIR/overlay/$CATEGORY/$NAME"
	cp "/usr/portage/$CATEGORY/$NAME/$NAME-$VERSION.ebuild" "$SCRIPT_DIR/overlay/$CATEGORY/$NAME"
	cp "/usr/portage/$CATEGORY/$NAME/metadata.xml" "$SCRIPT_DIR/overlay/$CATEGORY/$NAME"
}

function REPOMAN() {
	DATE=$(date +%s)
	mkdir -p "$SCRIPT_DIR/repo-logs/$CATEGORY/$NAME-$VERSION/$DATE"
	cd "$SCRIPT_DIR/overlay/$CATEGORY/$NAME"
	repoman scan || true
	repoman --digest=y full > "$SCRIPT_DIR/repo-logs/$CATEGORY/$NAME-$VERSION/$DATE/current.txt" || true
	sed -i -e "/^USE_RUBY/s/$CURR_TARGET/$CURR_TARGET $NEXT_TARGET/" "$NAME-$VERSION.ebuild"
	repoman --digest=y full > "$SCRIPT_DIR/repo-logs/$CATEGORY/$NAME-$VERSION/$DATE/next.txt" || true
}

function CLEANUP() {
	rm "$SCRIPT_DIR/overlay/$CATEGORY/$NAME/$NAME-$VERSION.ebuild"
	rm "$SCRIPT_DIR/overlay/$CATEGORY/$NAME/Manifest"
	rm "$SCRIPT_DIR/overlay/$CATEGORY/$NAME/metadata.xml"
	rm -r /usr/portage/distfiles/*
}

ENV_SETUP
PACKAGES=("$@")
for PACKAGE in "${PACKAGES[@]}"; do
	read -a PKG_ARR <<< "$PACKAGE"
	CATEGORY="${PKG_ARR[0]}"
	NAME="${PKG_ARR[1]}"
	VERSION="${PKG_ARR[2]}"
	CURR_TARGET="${PKG_ARR[3]}"
	NEXT_TARGET="${PKG_ARR[4]}"

	SETUP
	REPOMAN
	CLEANUP
done
