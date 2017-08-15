#!/bin/bash

#This will update the Atom editor.

#Make some vars.
type="deb" #Can only be rpm or deb
url="https://atom.io/download/$type"
pkg="/tmp/atom-editor.$type"


#Download the package.
echo "Getting package..."
wget -q -O $pkg $url

#Check if the version downloaded is newer than the current.
function deb-v {
    new=`dpkg-deb -f $pkg Version`
    old=`apt version atom`
}
function rpm-v {
    new=`rpm -qp --queryformat '%{VERSION}' $pkg`
    old=`rpm -q --queryformat '%{VERSION}' atom`
}

#Run the appropreate version check.
echo "Calling $type-v"
$type-v
if [[ "$old" == "$new" ]]; then
    echo "No updates."
    exit 0
fi

#Wait for the editor to close.
echo "Waiting for editor to close..."
while [[ `ps -eo "%p %c" | grep -e '\satom$' | wc -l` -ne 0 ]]; do
    sleep 1;
done

#Throwing up the package installer
function deb-i {
    gdebi-gtk $pkg
}
function rpm-i {
    /sbin/yast2 sw_single $pkg
}

#Call the correct installer.
echo "Installing with $type-i"
$type-i

#Update any other packages
echo "Updating packages..."
apm upgrade --no-confirm

echo "Done"
exit 0
