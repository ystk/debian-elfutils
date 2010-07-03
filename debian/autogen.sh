#!/bin/sh
#
# autogen.sh glue for hplip
#
# HPLIP used to have five or so different autotools trees.  Upstream
# has reduced it to two.  Still, this script is capable of cleaning
# just about any possible mess of autoconf files.
#
# BE CAREFUL with trees that are not completely automake-generated,
# this script deletes all Makefile.in files it can find.
#
# Requires: automake 1.9, autoconf 2.57+
# Conflicts: autoconf 2.13
set -e

# Refresh GNU autotools toolchain.
echo Cleaning autotools files...
find -type d -name autom4te.cache -print0 | xargs -0 rm -rf \;
find -type f \( -name missing -o -name install-sh \
	-o -name depcomp -o -name ltmain.sh -o -name configure \
	-o -name config.sub -o -name config.guess \
	-o -name Makefile.in \) -print0 | xargs -0 rm -f

echo Running autoreconf...
autoreconf --force --install

# For the Debian package build
test -d debian && {
	# refresh list of executable scripts, to avoid possible breakage if
	# upstream tarball does not include the file or if it is mispackaged
	# for whatever reason.
	[ "$1" = "updateexec" ] && {
		echo Generating list of executable files...
		rm -f debian/executable.files
		find -type f -perm +111 ! -name '.*' -fprint debian/executable.files
	}

        # run debian/rules clean to remove stuff like autom4te.cache,
        # config.{guess,sub},..

        fr=$(which fakeroot)
        if [ -n "$fr" ]; then
            "$fr" make -f debian/rules clean
        fi
}

exit 0
