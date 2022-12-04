#!/bin/bash -ueo

# Copyright (c) 2022 Naoki Takahashi
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

if [ -z "${IGNITION_VERSION}" ]
then
    echo "Empty IGNITION_VERSION variable"
    return 2
else
    echo "IGNITION_VERSION is ${IGNITION_VERSION}"
fi

build_thread=$((`nproc`/2))

if [ 0 -eq $build_thread ]
then
    build_thread=1
fi

os_version_codename=$(grep VERSION_CODENAME /etc/os-release | awk -F '[=]' '{print $2}')
ogre_apt_package=""

if [ "$os_version_codename" = "jammy" ]
then
    ogre_apt_package="libogre-1.9-dev libogre-next-dev"
elif [ "$os_version_codename" = "focal" ]
then
    ogre_apt_package="libogre-1.9-dev libogre-2.2-dev"
else
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive \
&& export CC=gcc-9 \
&& export CXX=g++-9 \
&& apt-get update --quiet --fix-missing \
&& apt-get install --yes --quiet --no-install-recommends \
    git \
    gcc-9 \
    g++-9 \
    cmake \
    make \
    ninja-build \
    python3-vcstool \
    python3-colcon-common-extensions \
&& apt-get install --yes --quiet --no-install-recommends \
    libbullet-dev \
    libbullet-extras-dev \
    $ogre_apt_package \
    libxaw7-dev \
    binutils-dev \
    freeglut3-dev \
    libassimp-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavformat-dev \
    libavutil-dev \
    libbenchmark-dev \
    libcurl4-openssl-dev \
    libdart-collision-bullet-dev \
    libdart-collision-ode-dev \
    libdart-dev \
    libdart-external-ikfast-dev \
    libdart-external-odelcpsolver-dev \
    libdart-utils-urdf-dev \
    libeigen3-dev \
    libfreeimage-dev \
    libgdal-dev \
    libgflags-dev \
    libglew-dev \
    libgts-dev \
    libjsoncpp-dev \
    libprotobuf-dev \
    libprotoc-dev \
    libpython3-dev \
    libsqlite3-dev \
    libswscale-dev \
    libtinyxml2-dev \
    liburdfdom-dev \
    libwebsockets-dev \
    libxi-dev \
    libxml2-utils \
    libxmu-dev \
    libyaml-dev \
    libzip-dev \
    libzmq3-dev \
    pkg-config \
    protobuf-compiler \
    python3-dev \
    python3-distutils \
    python3-psutil \
    python3-pybind11 \
    python3-yaml \
    qml-module-qt-labs-folderlistmodel \
    qml-module-qt-labs-platform \
    qml-module-qt-labs-settings \
    qml-module-qtcharts \
    qml-module-qtgraphicaleffects \
    qml-module-qtlocation \
    qml-module-qtpositioning \
    qml-module-qtqml-models2 \
    qml-module-qtquick-controls \
    qml-module-qtquick-controls2 \
    qml-module-qtquick-dialogs \
    qml-module-qtquick-layouts \
    qml-module-qtquick-templates2 \
    qml-module-qtquick-window2 \
    qml-module-qtquick2 \
    qtbase5-dev \
    qtdeclarative5-dev \
    qtquickcontrols2-5-dev \
    rubocop \
    ruby \
    ruby-dev \
    swig \
    uuid-dev \
    xvfb \
&& mkdir -p ign_${IGNITION_VERSION}_ws/src \
&& cd ign_${IGNITION_VERSION}_ws \
&& wget https://raw.githubusercontent.com/ignition-tooling/gazebodistro/master/collection-${IGNITION_VERSION}.yaml \
&& vcs import src < collection-${IGNITION_VERSION}.yaml \
    --recursive \
&& colcon build \
    --merge-install \
    --executor sequential \
    --parallel-workers $build_thread \
    --install-base /opt/gz/${IGNITION_VERSION} \
    --cmake-args \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_STANDARD_LIBRARIES="-lpthread" \
        -DCMAKE_SHARED_LINKER_FLAGS="-lpthread" \
        -DBUILD_TESTING=false \
        -DCMAKE_POSITION_INDEPENDENT_CODE=true \
&& cd ../ \
&& rm -rf ign_${IGNITION_VERSION}_ws \
&& apt-get remove --purge --yes \
    gnupg2 \
    ninja-build \
    gcc-9 \
    g++-9 \
&& apt-get autoremove --yes \
|| exit 1

if [ -d ign_${IGNITION_VERSION}_ws/install/lib/ignition/ignition-common4 ]
then
    ln \
        -s ign_${IGNITION_VERSION}_ws/install/libexec/ignition/ignition-common4 \
           ign_${IGNITION_VERSION}_ws/install/lib/ignition/ignition-common4
fi

if [ -d ign_${IGNITION_VERSION}_ws/install/lib/ignition/transport11 ]
then
    ln \
        -s ign_${IGNITION_VERSION}_ws/install/libexec/ignition/transport11 \
           ign_${IGNITION_VERSION}_ws/install/lib/ignition/transport11
fi
