## Introduction
The Mac Toolkit is a collection of system administration and diagnostic tools for OS X

## License
DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
                    Version 2, December 2004 

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net> 

 Everyone is permitted to copy and distribute verbatim or modified 
 copies of this license document, and changing it is allowed as long 
 as the name is changed. 

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 

  0. You just DO WHAT THE FUCK YOU WANT TO.

## build_rsync
A helper for building the latest rsync, complete with all Mac-specific patches.

## hellyes
A stress test which starts a yes process per every core and then generates IO on 
the boot drive by creating 10k, 100k, 1m and 10m files in the /tmp/_hellyes folder.

## poweron
Tool for testing intermittent sleep issues. Works by scheduling 

## blooper
The Boot Looper is another stress test which opens up a bunch of applications and then
reboots the machine. Very effective when used inside login items. Has two modes of operation:
- Run as is. This launches the first 5 apps from /Applications
- Create a folder called "TestApps" on your desktop and drag aliases into it.
This will only launch the apps inside this folder.

## cyclone
Clones entire drives. Tries to be more efficient than just using dd.

## netbless
Netbless is a very simple tool to help AASPs match a machine to it's proper installation media.
It requires both a client and a server to function, and

