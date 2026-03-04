### nhobs -- ooh err. NetHack OBS.

Small script to "save scumm" a nethack installation.

Creates little separate dungeons without chroots, etc. \
Not perfect but useful enough for my purposes.

It makes an assumption that nethack \
is installed in the following location: /var/games/nethack

I'm making a Dockerfile (WIP) to use alpine to install nethack \ 
and guarantee the installation directory.  I'll try and upload it later...

### USAGE

`nh-obs.sh -d hack-1a`

e.g., \
```bash
> nh-obs.sh -d hack-1a

It's too dark to find the hackdir! "hack-1a"
read an uncursed scroll of create directory? [Y/n]
You read an uncursed scroll of create directory.
Now re-cast this script to enter the maze.
```
