#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <quilt patches dir>" >&2
    echo "  e.g. $0 debian/patches" >&2
    exit 1
fi

patches="$1"
series="$patches/series"

if [ ! -e "$series" ]; then
    echo "Error: no series file found in the patch dir" >&2
    exit 1
fi

sed -n -e '1! G; $ p; h' "$series" | while read line; do
        patch=`echo "$line" | sed -e 's/ .*//'`
        params=`echo "$line" | sed -n -e 's/[^[:blank:]]* //p'`

        echo patch -R ${params:--p1} '<' "$patches/$patch"
        patch -R ${params:--p1} < "$patches/$patch"
        echo
    done
