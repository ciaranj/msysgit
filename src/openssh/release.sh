#!/bin/sh

cd "$(dirname "$0")"

VERSION=5.9p1
DIR=openssh-$VERSION

URL=http://mirror.bytemark.co.uk/OpenBSD/OpenSSH/portable/$DIR.tar.gz
FILE=${URL##*/}

die () {
	echo "$*" >&2
	exit 1
}

test -d $DIR || {
	test -f $FILE ||
	curl -O $URL ||
	die "Could not download $FILE"

	tar xzvf $FILE && (
		cd $DIR &&
		git init &&
		git add . &&
		git commit -m "Import of $FILE" &&
		patch -p1 < ../$DIR-win32.patch
	)
} || die "Could not check out $FILE"

export CPPFLAGS="-mno-cygwin -I$PWD/openbsd-compat -I $PWD/contrib/win32/win32compat/includes"
export LDFLAGS="-mno-cygwin"

(cd $DIR &&
./configure --build=i686-pc-mingw32 --host=i686-pc-mingw32 &&
cat config.h.tail >> config.h &&
make ssh.exe &&
make ssh-add.exe &&
make ssh-agent.exe &&
make ssh-keygen.exe &&
make ssh-keyscan.exe
) || die "Could not install $FILE"
