# Makefile for the YAMS modified version of MARS.
# Use command `make mars` (or just `make`) to create a JAR.
JAVA_DIR=java
MARS_DIR=mars-sockets
SYSCALL_DIR=mars/mips/instructions/syscalls
MARS_URL=http://courses.missouristate.edu/KenVollmar/MARS/MARS_4_5_Aug2014/Mars4_5.jar
JAR_NAME=Mars4_5-SockMod.jar
VANILLA_JAR=Mars4_5.jar

JAVA_SOURCES=$(shell find $(JAVA_DIR)/ -type f -name "*.java")
JAVA_CLASSES=$(patsubst %.java,%.class,$(patsubst $(JAVA_DIR)/%,$(MARS_DIR)/%,$(JAVA_SOURCES)))

all: mars

# Clean doesn't remove the vanilla JAR.  Delete it manually if you want to.
clean:
	rm -rf $(MARS_DIR) $(JAR_NAME)

.PHONY: all mars clean

mars: $(JAR_NAME)

# Rule for creating the modified JAR.
$(JAR_NAME): $(MARS_DIR)/CreateMarsJar.bat $(JAVA_CLASSES)
	cp -r $(JAVA_DIR) $(MARS_DIR) # Get source files in the JAR too!
	cd $(MARS_DIR); sh CreateMarsJar.bat; mv Mars.jar ../$(JAR_NAME)

# Rule for downloading vanilla JAR.
$(VANILLA_JAR):
	wget $(MARS_URL)

# Rule for extracting the JAR.
$(MARS_DIR)/CreateMarsJar.bat: $(VANILLA_JAR)
	mkdir -p $(MARS_DIR)
	cd $(MARS_DIR); jar xf ../$(VANILLA_JAR)

# Rule for compiling any Java file from JAVA_DIR into MARS_DIR.
$(MARS_DIR)/%.class: $(MARS_DIR)/CreateMarsJar.bat $(JAVA_DIR)/%.java
	javac -cp $(MARS_DIR) -d $(MARS_DIR) $(word 2,$^)


# Explicit dependencies:
$(JAVA_DIR)/$(SYSCALL_DIR)/SyscallServerSocketAccept.java: $(MARS_DIR)/$(SYSCALL_DIR)/Sockets.class
$(JAVA_DIR)/$(SYSCALL_DIR)/SyscallServerSocketBind.java: $(MARS_DIR)/$(SYSCALL_DIR)/Sockets.class $(MARS_DIR)/$(SYSCALL_DIR)/SocketUtils.class
$(JAVA_DIR)/$(SYSCALL_DIR)/SyscallServerSocketClose.java: $(MARS_DIR)/$(SYSCALL_DIR)/Sockets.class
$(JAVA_DIR)/$(SYSCALL_DIR)/SyscallServerSocketOpen.java: $(MARS_DIR)/$(SYSCALL_DIR)/Sockets.class
$(JAVA_DIR)/$(SYSCALL_DIR)/SyscallSocketClose.java: $(MARS_DIR)/$(SYSCALL_DIR)/Sockets.class
$(JAVA_DIR)/$(SYSCALL_DIR)/SyscallSocketOpen.java: $(MARS_DIR)/$(SYSCALL_DIR)/Sockets.class $(MARS_DIR)/$(SYSCALL_DIR)/SocketUtils.class
$(JAVA_DIR)/$(SYSCALL_DIR)/SyscallSocketRead.java: $(MARS_DIR)/$(SYSCALL_DIR)/Sockets.class
$(JAVA_DIR)/$(SYSCALL_DIR)/SyscallSocketWrite.java: $(MARS_DIR)/$(SYSCALL_DIR)/Sockets.class $(MARS_DIR)/$(SYSCALL_DIR)/SocketUtils.class
