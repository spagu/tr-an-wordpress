#!/bin/sh
# Autodetect the current version of -CURRENT on freebsd.org.
# This assumes the template boot command is still valid.
# Any arguments are passed to the packer instance.

URL="ftp://ftp.FreeBSD.org/pub/FreeBSD/snapshots/ISO-IMAGES/11.0/"

error() {
	echo "$0: ERROR: $1"
	[ -n "$2" ] && echo "$2"
	exit 1
}

which curl >/dev/null 2>&1 || error "Curl required, but not available?"

echo "Looking for latest -CURRENT from ${URL} ..."

cksumfile=$(curl -sl ${URL} | grep SHA256 | grep amd64 | sort | tail -1)
[ -z "$cksumfile" ] && error "Could not detect the latest checksum file"

cksumline=$(curl -so - ${URL}/${cksumfile} | grep 'disc1\.iso)')
[ -z "$cksumline" ] && error "Could not pull the latest checksum file"

isofile=$(echo $cksumline | awk -F\( '{print $2}' | awk -F\) '{print $1}')
cksum=$(echo $cksumline | awk '{print $4}')
[ -z "$isofile" -o -z "$cksum" ] && \
	error "Pulled latest checksum file, but could not parse line:" \
	    "  $cksumline"

rev=$(echo $isofile | awk -Famd64- '{print $2}' | awk -F-disc1.iso '{print $1}')
[ -z "$rev" ] && error \
	"Could not detect ISO date/revision in '${isofile}':" \
	"  $cksumline"

echo "Using ${isofile} (checksum ${cksum}) ..."

packer build \
	-var "iso_daterev=${rev}" \
	-var "iso_checksum=${cksum}" \
	$* \
	template-current.json
