#!/bin/bash

outdir_base='pkg'

clone_pkg() {
	local pkg="$1"
	local outdir="$outdir_base/$pkg"
	local git_url="https://aur.archlinux.org/$pkg.git"

	if [ -e "$outdir" ]; then
		rm -rf $outdir
	else
		mkdir -p $outdir
	fi

	git clone $git_url $outdir
}

patch_pkg() {
	local pkg="$1"

	for patch in patches/$pkg/*.patch; do
		echo "Applying $patch"
		(cd $outdir_base; git apply ../$patch)
	done
}

if [ ! -d "patches/$1" ]; then
	if [ "$2" == 'setup' ]; then
		# Set up a package for patch creation
		clone_pkg "$1"
		pkg_outdir="$outdir_base/$1"
		cp -r "$pkg_outdir" "$pkg_outdir-original"
		exit 0
	else
		echo "no patches exist for $1, exiting" &>2
		exit 1
	fi
fi

clone_pkg "$1"
patch_pkg "$1"
