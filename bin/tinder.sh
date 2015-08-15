#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
[[ $(whoami) == "root" ]] || exit 1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function ENV_SETUP() {
	eselect news read --quiet all
	eselect ruby set 1
	if [[ ! -d /etc/portage/env/ ]]; then
		mkdir /etc/portage/env/
	fi
	echo 'FEATURES="${FEATURES} test keepwork"' > /etc/portage/env/test

	if [[ ! -d $SCRIPT_DIR/ci-logs/ ]]; then
		mkdir "$SCRIPT_DIR/ci-logs"
	fi
}

function SETUP () {
	cp /var/lib/portage/world /var/lib/portage/world.original
	echo "" > /etc/portage/package.accept_keywords
	echo "=$PACKAGE doc" > /etc/portage/package.use
	echo "=$PACKAGE test" > /etc/portage/package.env

	if [[ -e /usr/portage/packages/$PACKAGE.tbz2 ]]; then
		rm "/usr/portage/packages/$PACKAGE.tbz2"
	fi

	if [[ $TYPE == "next_target" ]]; then
		mkdir -p "$SCRIPT_DIR/overlay"
		mkdir -p "$SCRIPT_DIR/overlay/$CATEGORY/$NAME"
		cp "/usr/portage/$CATEGORY/$NAME/$NAME-$VERSION.ebuild" "$SCRIPT_DIR/overlay/$CATEGORY/$NAME"
		cp "/usr/portage/$CATEGORY/$NAME/metadata.xml" "$SCRIPT_DIR/overlay/$CATEGORY/$NAME"
		cp -r "/usr/portage/$CATEGORY/$NAME/files" "$SCRIPT_DIR/overlay/$CATEGORY/$NAME" || true

		(
		cd "$SCRIPT_DIR/overlay/$CATEGORY/$NAME"
		sed -i -e "/^USE_RUBY/s/=\"/=\"$NEXT_TARGET /" "$NAME-$VERSION.ebuild"
		repoman manifest
		repoman full
		)
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
	LOG "$?"
	set -e
}

function LOG() {
	DATE=$(date +%s)
	SHA1=$(sha1sum "/usr/portage/$CATEGORY/$NAME/$NAME-$VERSION.ebuild" | awk '{print $1}')
	mkdir -p "$SCRIPT_DIR/ci-logs/$SHA1/$TYPE/builds/$DATE"

	emerge --info "=$PACKAGE" > "$SCRIPT_DIR/ci-logs/$SHA1/$TYPE/builds/$DATE/emerge-info"
	emerge -pqv "=$PACKAGE" > "$SCRIPT_DIR/ci-logs/$SHA1/$TYPE/builds/$DATE/emerge-pqv"
	cp "/var/tmp/portage/$PACKAGE/temp/build.log" "$SCRIPT_DIR/ci-logs/$SHA1/$TYPE/builds/$DATE/build.log"
	cp "/var/tmp/portage/$PACKAGE/temp/environment" "$SCRIPT_DIR/ci-logs/$SHA1/$TYPE/builds/$DATE/environment"
	gem list > "$SCRIPT_DIR/ci-logs/$SHA1/$TYPE/builds/$DATE/gem-list"

	if [[ $1 == 0 ]]; then
		RESULT="\e[0;32mBUILD SUCCEEDED\e[0m"
		echo "succeeded" > "$SCRIPT_DIR/ci-logs/$SHA1/$TYPE/builds/$DATE/result"
	elif [[ $1 == 1 ]]; then
		RESULT="\e[0;31mBUILD FAILED\e[0m"
		echo "failed" > "$SCRIPT_DIR/ci-logs/$SHA1/$TYPE/builds/$DATE/result"
	elif [[ $1 == 124 ]]; then
		RESULT="\e[0;31mBUILD TIMED OUT\e[0m"
		echo "timed out" > "$SCRIPT_DIR/ci-logs/$SHA1/$TYPE/builds/$DATE/result"
	else
		RESULT="\e[0;31mBUILD UNKNOWN\e[0m"
		echo "unknown" > "$SCRIPT_DIR/ci-logs/$SHA1/$TYPE/builds/$DATE/result"
	fi

	chmod 755 -R "$SCRIPT_DIR/ci-logs/$SHA1/$TYPE/builds/$DATE"
}

function CLEANUP() {
	mv /var/lib/portage/world.original /var/lib/portage/world
	rm -r /var/tmp/portage/* || true
	emerge --depclean --quiet
	echo -e "$PACKAGE : $RESULT"

	if [[ $TYPE == "next_target" ]]; then
		rm -r "$SCRIPT_DIR/overlay"
	fi
}

ENV_SETUP

PKG_ARR=($(qatom "$1"))
CATEGORY="${PKG_ARR[0]}"
NAME="${PKG_ARR[1]}"
if [[ ${PKG_ARR[3]:=foo} == "foo" ]]; then
	VERSION="${PKG_ARR[2]}"
else
	VERSION="${PKG_ARR[2]}-${PKG_ARR[3]}"
fi

if [[ $# -eq 1 ]]; then
	TYPE="current_target"
	PACKAGE=$1
	SETUP
	EMERGE
	CLEANUP
elif [[ $# -eq 2 ]]; then
	TYPE="current_target"
	PACKAGE=$1
	SETUP
	EMERGE
	CLEANUP

	TYPE="next_target"
	PACKAGE=$1
	NEXT_TARGET=$2
	SETUP
	EMERGE
	CLEANUP
fi
