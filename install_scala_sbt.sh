#!/bin/sh
# Author: Nikita Kovalev, https://gist.github.com/maizy/c4d31c1f539694f721f6
# Based on: https://gist.github.com/visenger/5496675

# Use java7 dependency (openjdk) instead of java6.

# Tested in Ubuntu 12.04.5 (precise)

SCALA="2.11.2"
SBT="0.13.5"
JRE="openjdk-7-jre"
JRE_HEADLESS="openjdk-7-jre-headless"

# --
sudo apt-get install dpkg fakeroot
TMP_DIR="/tmp/rebuild_tmp_`date '+%Y%m%d%H%M%S'`"

# -- scala package (you can comment this section if you don't need it)

wget --continue "http://www.scala-lang.org/files/archive/scala-$SCALA.deb"
echo 'patch scala package ...'
# patch scala .deb package for using default-jre instead of java6 runtime
fakeroot -- sh -c "
mkdir ${TMP_DIR}
dpkg-deb -R scala-${SCALA}.deb ${TMP_DIR}
sed 's/Version: ${SCALA}/Version: ${SCALA}~defjre/' <${TMP_DIR}/DEBIAN/control >tmpfile; mv -f tmpfile ${TMP_DIR}/DEBIAN/control 
sed 's/Depends: openjdk-6-jre | java6-runtime/Depends: ${JRE}/' <${TMP_DIR}/DEBIAN/control >tmpfile; mv -f tmpfile ${TMP_DIR}/DEBIAN/control 
dpkg-deb -b ${TMP_DIR} scala-${SCALA}_defjre.deb
rm -r ${TMP_DIR}
"

sudo apt-get remove scala-library scala
sudo apt-get install "${JRE}"
sudo dpkg -i "scala-${SCALA}_defjre.deb"

# -- sbt package (you can comment this section if you don't need it)
wget --continue "http://dl.bintray.com/sbt/debian/sbt-${SBT}.deb"
echo 'patch sbt package ...'
# patch sbt .deb package for using default-jre instead of java6 runtime
fakeroot -- sh -c "
mkdir ${TMP_DIR}
dpkg-deb -R sbt-${SBT}.deb ${TMP_DIR}
sed 's/Version: ${SBT}/Version: ${SBT}~defjre/' <${TMP_DIR}/DEBIAN/control >tmpfile; mv -f tmpfile ${TMP_DIR}/DEBIAN/control 
sed 's/Depends: java6-runtime-headless/Depends: ${JRE_HEADLESS}/' <${TMP_DIR}/DEBIAN/control >tmpfile; mv -f tmpfile ${TMP_DIR}/DEBIAN/control 
dpkg-deb -b ${TMP_DIR} sbt-${SBT}_defjre.deb
rm -r ${TMP_DIR}
"
sudo apt-get remove sbt
sudo apt-get install "${JRE_HEADLESS}"
sudo dpkg -i "sbt-${SBT}_defjre.deb"

# -- check
echo "installed versions"
dpkg -l scala sbt
