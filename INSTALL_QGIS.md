![QGIS](qgis_logo.png)

# Install QGIS

This document describes the steps to install QGIS v3 in your system.
The recommended approach is to [install it natively in your platform](#native-installation).
If that does not work, you may try to [run QGIS in a docker container](#use-docker). If none of these methods work, you may try to [run QGIS whithin a virtualbox image](#use-virtualbox).

## Native Installation

Follow these instructions to install QGIS in your platform:

https://www.qgis.org/en/site/forusers/download.html

## Use docker

Create a bash script with this content, changing `/home/$USER` to a local path in your OS, if necessary:

```bash
#!/bin/bash

xhost +
docker run --rm -it --name qgis \
    -v /home/$USER/:/mnt \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix$DISPLAY \
    qgis/qgis:latest qgis
xhost -

```
Or download it directly from [here](https://raw.githubusercontent.com/doublebyte1/bts_geospatial/master/run_qgis.sh).

Run the script to start QGIS.

## Use virtualbox

If nothing else works, download the [OSGeo Live](https://live.osgeo.org/en/download.html) virtual machine. The direct link is [here](https://sourceforge.net/projects/osgeo-live/files/12.0/osgeolive-12.0-vm.7z/download).

Install [virtualbox](https://www.virtualbox.org/) and [follow these instructions](https://live.osgeo.org/en/quickstart/virtualization_quickstart.html) to get OSGeo Live running on your system.

The OSGeo Live image contains many GIS software packages, other than QGIS. Follow this link to find out the packages contained in the OSGeo Live distribution:

https://live.osgeo.org/en/overview/overview.html
