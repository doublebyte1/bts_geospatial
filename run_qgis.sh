#!/bin/bash

xhost +
docker run --rm -it --name qgis \
    -v /home/$USER/:/mnt \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix$DISPLAY \
    qgis/qgis:latest qgis
xhost -
