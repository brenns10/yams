#!/bin/sh
SYSCALL_DIR=mars/mips/instructions/syscalls
MARS_DIR=mars-sockets
MARS_URL=http://courses.missouristate.edu/KenVollmar/MARS/MARS_4_5_Aug2014/Mars4_5.jar
JAVA_DIR=java
JAR_NAME=Mars4_5.jar

# Download & extract MARS Jar.
rm -rf $MARS_DIR
mkdir -p $MARS_DIR
cd $MARS_DIR
wget $MARS_URL
jar xf $JAR_NAME
rm -f $JAR_NAME
cd ..

# Compile every file that has been modified since our reference file.
# HACK: sorted order happens to work out the dependencies in the files!
for java_file in $(find $JAVA_DIR/$SYSCALL_DIR -type f | sort); do
    javac -cp $MARS_DIR -d $MARS_DIR $java_file
done

# Create a Jar!  Reuse the script that comes with MARS.  It says it's a batch
# script, but it's really just a single command saved in a text file.
cd $MARS_DIR
sh CreateMarsJar.bat
mv Mars.jar ../Mars4_5-SockMod.jar
cd ..
rm -rf $MARS_DIR
