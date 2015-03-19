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

## Development Tasks
Assignments are general and collaboration is important.
  - [ ] Final Socket implementation: due 27 March, by Jeff
  - [ ] Establish calling convention: due 27 March, by all
  - [ ] HTTP request parsing: due 10 April
    - [ ] String methods -- Stephen
    - [ ] HTTP business logic -- Jeff
  - [ ] HTTP response building: due 24 April
    - [ ] Additional string methods -- Stephen
    - [ ] Invalid request method case -- Aaron
    - [ ] File finding and loading -- Thomas
    - [ ] Invalid URI case -- Andrew/Katherine
    - [ ] Valid URI case -- Andrew/Katherine
  - [ ] HTML+Content files to serve: ongoing as HTTP features developed
    - [ ] Basic, static, single-page HTML -- Thomas
    - [ ] Static, multi-page, linked HTML -- Aaron
    - [ ] Addition of visual effect media (CSS, JS) -- Andrew
    - [ ] Addition of binary media (images) -- Stephen
  - [ ] Stretch features: as time/difficulty allows
    - [ ] Config file with redirects, custom port
    - [ ] Moustache templating
    - [ ] Magic POST field for Whitespace interpretation
  - [ ] Report: due 5/1, by all

