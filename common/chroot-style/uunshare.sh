#!/bin/sh
#
# This chroot script uses xbps-uunshare(1) with user_namespaces(7).
#
readonly MASTERDIR="$1"
readonly DISTDIR="$2"
readonly HOSTDIR="$3"
readonly EXTRA_ARGS="$4"
readonly CMD="$5"
shift 5

msg_red() {
	# error messages in bold/red
	[ -n "$NOCOLORS" ] || printf >&2 "\033[1m\033[31m"
	printf "=> ERROR: %s\\n" "$@" >&2
	[ -n "$NOCOLORS" ] || printf >&2 "\033[m"
}

if ! command -v xbps-uunshare >/dev/null 2>&1; then
	msg_red "could not find xbps-uunshare"
	exit 1
fi

if [ -z "$MASTERDIR" -o -z "$DISTDIR" ]; then
	msg_red "$0: MASTERDIR/DISTDIR not set"
	exit 1
fi

if command -v unshare >/dev/null 2>&1; then
	if ! unshare -r true >/dev/null 2>&1 && ! unshare -U true >/dev/null 2>&1; then
		msg_red "unprivileged user namespaces are not permitted in this environment"
		msg_red "Please set XBPS_CHROOT_CMD to 'ethereal', 'uchroot', or 'bwrap' in etc/conf"
		exit 1
	fi
fi

exec xbps-uunshare $EXTRA_ARGS -b $DISTDIR:/void-packages ${HOSTDIR:+-b $HOSTDIR:/host} -- $MASTERDIR $CMD $@
