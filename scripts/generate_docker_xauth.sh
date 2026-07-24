#!/bin/sh
mkdir /tmp/rose
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f /tmp/rose/docker.$USER.xauth nmerge -
