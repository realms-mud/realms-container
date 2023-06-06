# Introduction 
This project wraps the Realms Core Lib project (https://github.com/realms-mud/core-lib) 
and the ldmud driver (https://github.com/ldmud/ldmud) in a Docker container 
**FOR EVALUATION AND TESTING PURPOSES ONLY**. It does **NOT** provide persistent storage
outside the lifetime of a running instance as it is currently set up. 

To use this after you have Docker (https://www.docker.com/) installed, from a command line do the following:

```
# cd <location of this repo>
# docker build -t realms .
```
You can then run it in one of two ways:
```
# docker run -it realms
```
You will see the database start up and the mud load itself
```
# telnet localhost
```
You can also run the container such that it exposes the mud outside of Docker by doing this:
```
# docker run -d -P realmsdocker run -d -P realms
```
You can find out which port the mud is exposed on using 
```
docker run -d -P realms
```
Where you will get output like this:
```
CONTAINER ID   IMAGE     COMMAND                  CREATED             STATUS                          PORTS                   NAMES
d79c9e7ad5c4   realms    "/bin/sh -c 'service…"   About an hour ago   Up About an hour                0.0.0.0:32768->23/tcp   confident_hawking
```
In this example, you could telnet to your machine, port 32768 and connect to the mud.

## ERRATA
I am aware of a terminal issue wherein using colors does not format in 
an even remotely attractive manner if launched from the container. It's annoying
an ugly. If it bothers you, set the color to "none" either at character creation or
in game
```
> set -p color -v none
```
