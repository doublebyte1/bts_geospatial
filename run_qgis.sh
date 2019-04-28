#!/bin/bash

xhost +
docker run --rm -it --name qgis \
    -v "$PWD":/tmp \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix$DISPLAY \
    qgis/qgis:latest qgis
xhost -
