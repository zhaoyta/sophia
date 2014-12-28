#!/bin/sh

# sophia amalgamation build
#

process() {
	root=$1
	output=$2
	lib=$3
	dir=$4
	includes=`cat $root/$dir/$lib | sed -n 's/#include <\(.*\)>/\1/p'`
	for file in $includes; do
		echo "#line 1 \"$root/$dir/$file\"" >> $output
		cat "$root/$dir/$file" >> $output
	done
	files=`ls $root/$dir/*.c`
	for file in $files; do
		echo "#line 1 \"$file\"" >> $output
		cat "$file" | grep -v "include" >> $output
	done
}

if [ $# -ne 2 ]; then
	echo "sophia amalgamation build."
	echo "usage: $0 <sophia_root> <output>"
	return 1
fi

root=$1
output=$2

build=`git rev-parse --short HEAD`
build_date=`date`

rm -f $output
touch $output

cat <<EOF >> $output

/*
 * sophia database
 * sphia.org
 *
 * Copyright (c) Dmitry Simonenko
 * BSD License
*/

/* amalgamation build
 *
 * version:     1.2
 * build:       $build
 * build date:  $build_date
 *
 * compilation:
 * cc -O2 -DNDEBUG -std=c99 -pedantic -Wall -Wextra -pthread -c sophia.c
*/

/* {{{ */

#define SOPHIA_BUILD "$build"
EOF

process $root $output "libsr.h" "rt"
process $root $output "libsv.h" "version"
process $root $output "libsx.h" "transaction"
process $root $output "libsl.h" "log"
process $root $output "libsd.h" "database"
process $root $output "libsi.h" "index"
process $root $output "libse.h" "repository"
process $root $output "libso.h" "sophia"

cat <<EOF >> $output
/* vim: foldmethod=marker
*/
/* }}} */
EOF