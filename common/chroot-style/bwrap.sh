#!/bin/sh
#
# This chroot script uses bubblewrap (see https://github.com/containers/bubblewrap)
#
set -e
readonly MASTERDIR="$1"
readonly DISTDIR="$2"
readonly HOSTDIR="$3"
readonly EXTRA_ARGS="$4"
shift 4

msg_red() {
	# error messages in bold/red
	[ -n "$NOCOLORS" ] || printf >&2 "\033[1m\033[31m"
	printf "=> ERROR: %s\\n" "$@" >&2
	[ -n "$NOCOLORS" ] || printf >&2 "\033[m"
}

if ! command -v bwrap >/dev/null 2>&1; then
	msg_red "could not find bwrap"
	exit 1
fi

if [ -z "$MASTERDIR" ] || [ -z "$DISTDIR" ]; then
	msg_red "$0: MASTERDIR/DISTDIR not set"
	exit 1
fi

if [ -z "$XBPS_TEMP_MASTERDIR" ]; then
	exec bwrap --bind "$MASTERDIR" / \
		--ro-bind "$DISTDIR" /void-packages \
		--dev /dev --tmpfs /tmp --proc /proc --ro-bind /sys /sys \
		${HOSTDIR:+--bind "$HOSTDIR" /host} ${EXTRA_ARGS} "$@"
else
	exec bwrap --overlay-src "$MASTERDIR" --tmp-overlay / \
		--ro-bind "$DISTDIR" /void-packages \
		--dev /dev --tmpfs /tmp --proc /proc --ro-bind /sys /sys \
		${HOSTDIR:+--bind "$HOSTDIR" /host} ${EXTRA_ARGS} "$@"
fi
