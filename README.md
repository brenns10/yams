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

This project is a static HTTP server in MIPS, using MARS as a simulator.
Sockets are implemented by extending MARS syscalls in Java.  The server serves
static content from the `html` directory.  Features of YAMS include:

* Limited support for GET and POST requests, and standard HTTP responses.
* Support for serving large files (albeit slowly).
* Brainfuck interpreter accessed via POST request:
    * A web interface for this is available at `brainfuck.html`.
    * Code is POSTed to `/load`.
    * Input is POSTed to `/run`, and output is returned.

### How to Load Required Javascript Submodules

YAMS serves all required resources for our webpages.  One resource, for our
presentation, is `reveal.js`.  We linked to their git repository.  If you got
this by cloning the repository, you'll need to load the submodule.

* Run `git submodule init`.
* Run `git submodule update`.

### How to Run Modded MARS

This has been tested on Linux and Mac.  It almost certainly supports Windows,
however we have not tested this.  We cannot guarantee lack of unexpected
behavior.

  - Run `make mars`
  - Call `java -jar Mars4_5-SockMod.jar` (or double click the JAR, or something)
  - Enjoy!
