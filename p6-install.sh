#!/bin/bash

#(Re)install Rakudo Perl6.

#Make some vars
prefix="/usr/local"
workdir="/tmp/rakudo"
log="$workdir/build.log"


#Function to easily display warning messages.
function warn { echo $@ 1>&2; }


#Make sure that the arguments are correct.
if [[ $# -ne 1 ]]; then
    warn "Argument must be the rakudo version like '2017.05'"
    exit 1
fi

#Check for permissions.
if [[ `whoami` != "root" ]]; then
    warn "Must be run with sudo/root"
    exit 2
fi

#Prep things.
mkdir -p $workdir
rm -rf "$workdir/$1.tar.gz"
rm -rf "$workdir/$log"
rm -rf "$workdir/rakudo-$1"
touch "$log"
mkdir -p $prefix



#Download the desired version.
cd $workdir
wget "https://github.com/rakudo/rakudo/archive/$1.tar.gz" 2>&1 >>"$log"; code=$?
if [[ $code -ne 0 ]]; then
    warn "Could not download Rakudo version '$1'"
    exit 3
fi
tar -xvzf "$1.tar.gz"
cd "rakudo-$1"


#Configure and make Rakudo.
rm -rf $HOME/.perl6
perl Configure.pl --gen-moar --gen-nqp --backends=moar --prefix=$prefix 2>&1 >>"$log"
make -j8 test && make -j8 install
code=$?
if [[ $code -ne 0 ]]; then
    warn "A problem occured when configuring and making Rakudo."
    exit 4
fi
cd ..


#Install Zef.
git clone https://github.com/ugexe/zef.git;
cd zef;
/usr/local/bin/perl6 -Ilib bin/zef install . 2>&1 >>"$log"
code=$?
if [[ $code -ne 0 ]]; then
    warn "A problem occured when installing Zef."
    exit 5
fi
cd ..
