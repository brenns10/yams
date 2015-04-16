# yams
YAMS: Awesome MIPS Server

## Team HKNSoc (pronounced “hack-in-sock”)
  - Stephen Brennan (smb196)
  - Katherine Cass (krc53)
  - Jeffrey Copeland (jpc86)
  - Andrew Mason (ajm188)
  - Thomas Murphy (trm70)
  - Aaron Neyer (agn31)

## Description
The goal of this project is to write a static HTTP server in MIPS and MARS. The server will consume a root content directory and a port. The server will then serve the website which will be viewable from the browser. Sockets will be used for networking and will be available in MIPS by extending MARS syscalls.

### How to Run Modded MARS
This has been tested on Linux, but not Mac.  Certainly not Windows.
  - Run `make mars`
  - Call `java -jar Mars4_5-SockMod.jar` (or double click the JAR, or something)
  - If you have trouble, check the Google Drive folder for a premade copy.
  - Enjoy!
