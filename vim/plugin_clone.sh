#!/bin/bash
#
# Clone a repo into repos/ as a submodule,
# and then add a symbolic link to bundle/.
#

usage () {
    echo "Usage:"
    echo "    ./plugin_clone.sh GIT_URL"
}

if [ "$#" -ne 1 ] ; then
    usage
    exit 1
fi

# Make a tmp directory. This is a trick to
# get the default name of the cloned repo (maybe there is another way to do this, though).
rm -rf __tmp
mkdir __tmp

(
    cd __tmp
    git submodule add --force "$1"
)

name="$(ls __tmp)"
git mv "__tmp/$name" "repos/$name"
rm -rf __tmp

# By default enable the plugin.
ln -s -r "repos/$name" "bundle/$name"
echo "Enabled plugin \"$name\""
