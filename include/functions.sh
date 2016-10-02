#!/bin/bash
field_value() {
        KEY=$1
        FILE=$2

        REGEX="^$KEY="
        LINE=$(grep $REGEX $FILE)

        if [[ -z $LINE ]]; then
                echo "$KEY not found" >&2
                exit 1
        fi
        RESULT=$(cut -d "=" -f 2 <<< $LINE)

        echo $RESULT
}

cached_download() {
FILE=$1
URL=$2

if [ -f $FILE ]; then
        echo "File already exists - nothing to do" >&2
        return 0
fi

if [ ! -d "$(dirname $0)/cache/" ]; then
        mkdir "$(dirname $0)/cache/"
fi

CACHE="$(dirname $0)/cache/$FILE"

echo CACHE $CACHE >&2
if [ ! -f $CACHE ]; then
# Logic to download past bot protection on Curse
if [[ $URL =~ ^https:\/\/mods\.curse\.com\/mc-mods\/minecraft\/ ]]; then
URL=$(wget -O - -o /dev/null  $URL |  sed ':a:N:$!ba;s/\"/\n/g' \
| grep http://addons.curse.cursecdn.com/)
echo "Sleeping for 2 seconds to comply with Curse Terms of Service" >&2
sleep 2
fi

echo "Downloading $URL" >&2

wget $URL -O $CACHE -nc
fi
echo "Copying $CACHE -> $FILE" >&2
cp $CACHE $FILE
}