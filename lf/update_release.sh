#!/bin/bash
# Install a particular release of lf.
# note: man page is not on release page, not installing it here.

release_number="$1"
if [ $# -ne 1 ] || ! [[ $release_number =~ [0-9]+ ]]
then
    >&2 echo "usage: ./update_release.sh <release number>"
    exit 1
fi
release_url="https://github.com/gokcehan/lf/releases/download/r$release_number/lf-linux-amd64.tar.gz"
wget "$release_url"
tar xvf lf-linux-amd64.tar.gz
mv -f lf ~/bin/lf
rm lf-linux-amd64.tar.gz

echo '--------------------------------------------------------------------------------'
# Check if new version is installed.
echo "lf --version"
lf --version
