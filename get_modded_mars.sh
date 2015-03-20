#!/bin/sh
SYSCALL_DIR=mars/mips/instructions/syscalls
TOUCHED_FILE=__asdf.txt   # double underscore for extra security
MARS_DIR=mars-sockets
JAR_NAME=Mars4_5.jar
PATCH_NAME=mars-sockets.patch

touch $TOUCHED_FILE
rm -rf $MARS_DIR
mkdir -p $MARS_DIR
cd $MARS_DIR
wget http://courses.missouristate.edu/KenVollmar/MARS/MARS_4_5_Aug2014/Mars4_5.jar
jar xf $JAR_NAME
rm -f $JAR_NAME
patch -p1 < ../$PATCH_NAME
cd ..

for java_file in $(find $MARS_DIR/$SYSCALL_DIR -type f -newer $TOUCHED_FILE); do
    javac -cp $MARS_DIR $java_file
done

rm -f $TOUCHED_FILE

# Create a Jar!  Reuse the script that comes with MARS.  It says it's a bash
# script, but it's really just a single command saved in a text file.
cd $MARS_DIR
sh CreateMarsJar.bat
mv Mars.jar ../Mars4_5-SockMod.jar
cd ..
rm -rf $MARS_DIR
