# sudo for 2.11BSD PDP11/70

This is a port of era-appropriate sudo for the PDP11 running 2.11BSD.

You can find the [original README here](README_original).

This software is licenced under the [GPL version 2](COPYING) and is providied without warranty. USE AT YOUR OWN RISK. 

Port by Chris How with a lot of assistance from Claude Sonnet. 

## Installing

Build:
```
make 
```

Install:

`su` to root and run:
```
make install
```

Use `visudo` to make changes to `/etc/sudoers`.