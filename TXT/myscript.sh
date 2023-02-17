#!/bin/bash
# Copyright (C) 2020-2022 Cicak Bin Kadal

# This free document is distributed in the hope that it will be 
# useful, but WITHOUT ANY WARRANTY; without even the implied 
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# REV13: Wed 18 May 2022 22:00:00 WIB
# REV11: Sun 08 May 2022 06:00:00 WIB
# REV08: Sun 13 Mar 2022 23:16:47 WIB
# REV04: Sat 20 Nov 2021 19:10:06 WIB
# REV02: Sun 19 Sep 2021 15:44:11 WIB
# START: Mon 28 Sep 2020 21:05:04 WIB

# ATTN:
# You new to set "REC2" with your own Public-Key Identity!
# Check it out with "gpg --list-key"

WEEKS=(00 01 02 03 04 05 06 07 08 09 10 11)

function serialize_array() {
        declare -n _array="${1}" _str="${2}" # _array, _str => local reference vars
        local IFS="${3:-$'\x01'}"
        # shellcheck disable=SC2034 # Reference vars assumed used by caller
        _str="${_array[*]}" # * => join on IFS
}

REC2="6B8C635D2D20BB100C9C5092F3077ECF2B0B6169"
REC1="63FB12B215403B20"
FILES="my*.asc my*.txt my*.sh"
SHA="SHA256SUM"
RESDIR="$HOME/SP_RESULT/"

if command -v fzf &> /dev/null ; then
    serialize_array WEEKS WEEKS_SERIALIZED $'\n'
    WEEK=$(echo "$WEEKS_SERIALIZED" | fzf)
else
    WEEK="00"  # HARD CODE THIS IF NOT USING FZF
fi

[ -d $RESDIR ] || mkdir -p $RESDIR
pushd $RESDIR
for II in W?? ; do
    [ -d $II ] || continue
    TARFILE=my$II.tar.bz2
    TARFASC=$TARFILE.asc
    rm -vf $TARFILE $TARFASC
    echo "tar cfj $TARFILE $II/"
    tar cfj $TARFILE $II/
    echo "gpg --armor --output $TARFASC --encrypt --recipient $REC1 --recipient $REC2 $TARFILE"
    gpg --armor --output $TARFASC --encrypt --recipient $REC1 --recipient $REC2 $TARFILE
done
popd

if [[ "$WEEK" != "00" ]] ; then
    II="${RESDIR}myW$WEEK.tar.bz2.asc"
    echo "Check and move $II..."
    [ -f $II ] && mv -vf $II .
fi

echo "rm -f $SHA $SHA.asc"
rm -f $SHA $SHA.asc

echo "sha256sum $FILES > $SHA"
sha256sum $FILES > $SHA

echo "sha256sum -c $SHA"
sha256sum -c $SHA

echo "gpg --output $SHA.asc --armor --sign --detach-sign $SHA"
gpg --output $SHA.asc --armor --sign --detach-sign $SHA

echo "gpg --verify $SHA.asc $SHA"
gpg --verify $SHA.asc $SHA

echo ""
echo "==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ===="
echo "==== ==== ==== ATTN: is this WEEK $WEEK ?? ==== ==== ==== ===="
echo "==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ===="
echo ""

exit 0
