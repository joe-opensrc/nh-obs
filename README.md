### nhobs -- ooh err. NetHack OBS.

    Small script to "save scumm" a nethack installation.

    Creates little separate dungeons without chroots, etc.
    Not perfect but useful enough for my purposes.
    
    It makes an assumption that nethack
    is installed in the following location: /var/games/nethack

    There's a self-contained Dockerfile / container version also.

    Now with: nh-prices.sh
    ( a script to help with price identification of items )

### INSTALL
___

```bash
git clone https://github.com/joe-opensrc/nh-obs.git 
cd nh-obs
export PATH="${PWD}/bin:${PATH}"
```

```bash
docker build -t joe-opensrc/nethack:v3.6.7 .
```

### USAGE
___

`nh-obs.sh -d hack-1a`

e.g.,
```bash
> nh-obs.sh -d hack-1a

It's too dark to find the hackdir! "hack-1a"
Read an uncursed scroll of create directory? [Y/n]
You read an uncursed scroll of create directory.
Now re-cast this script to enter the maze.
```

or perhaps:

```bash
> nh-obs.sh -d hack-1a
> docker run --rm -v ./hack-1a:/opt/nethack -it joe-opensrc/nethack
```
