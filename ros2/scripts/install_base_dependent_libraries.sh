#!/bin/sh

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

build_thread=$((`nproc`/2))

if [ 0 -eq $build_thread ]
then
    build_thread=1
fi

export DEBIAN_FRONTEND=noninteractive \
&& export CXX=g++-11 \
&& export CC=gcc-11 \
&& apt-get update --quiet \
&& apt-get install --yes --quiet --no-install-recommends \
    software-properties-common \
    gpg-agent \
&& add-apt-repository ppa:ubuntu-toolchain-r/test \
&& apt-get install --yes --quiet --no-install-recommends \
    wget \
    git \
    unzip \
    ninja-build \
    g++-11 \
    gcc-11 \
    cmake \
    ca-certificates \
    libboost-system-dev \
    libboost-filesystem-dev \
    libboost-serialization-dev \
    libboost-thread-dev \
    libboost-timer-dev \
    libboost-chrono-dev \
    libboost-regex-dev \
    libboost-python-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    libatlas-base-dev \
    libeigen3-dev \
    libceres-dev \
    libusb-1.0-0-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libglfw3-dev \
    libpoco-dev \
    stow \
    liblua5.2-dev \
    coinor-libipopt-dev \
    libopencv-dev \
    libpcl-dev \
    nlohmann-json3-dev \
&& mkdir install_from_sources \
&& cd install_from_sources/ \
&& git clone --depth 1 https://github.com/rui314/mold.git \
&& mkdir mold/build \
&& cd mold/build \
&& cmake .. \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
&& ninja install -j $build_thread \
&& cd ../../ \
&& git clone --depth 1 -b development https://github.com/IntelRealSense/librealsense.git \
&& mkdir librealsense/build \
&& cd librealsense/build/ \
&& cmake \
    -G Ninja \
    -DCMAKE_LINKER=/usr/local/libexec/mold/ld \
    -DBUILD_EXAMPLES=false \
    -DGLFW_BUILD_EXAMPLES=false \
    -DBUILD_GRAPHICAL_EXAMPLES=false \
    -DBUILD_PCL_EXAMPLES=false \
    -DCMAKE_BUILD_TYPE=Release \
    .. \
&& mold -run ninja install -j $build_thread \
&& cd ../../ \
&& git clone --depth 1 https://github.com/borglab/gtsam.git \
&& mkdir gtsam/build \
&& cd gtsam/build/ \
&& cmake \
    -G Ninja \
    -DCMAKE_LINKER=/usr/local/libexec/mold/ld \
    -DGTSAM_BUILD_WITH_MARCH_NATIVE=false \
    -DGTSAM_BUILD_EXAMPLES_ALWAYS=false \
    -DGTSAM_BUILD_TESTS=false \
    -DCMAKE_BUILD_TYPE=Release \
    .. \
&& mold -run ninja install -j $build_thread \
&& cd ../../ \
&& git clone --depth 1 https://github.com/rbdl/rbdl.git \
    -b v3.2.1 \
    --recursive \
&& mkdir rbdl/build \
&& cd rbdl/build \
&& cmake \
    -G Ninja \
    -DCMAKE_LINKER=/usr/local/libexec/mold/ld \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=true \
    -DRBDL_BUILD_ADDON_URDFREADER=true \
    -DRBDL_BUILD_ADDON_GEOMETRY=true \
    .. \
&& mold -run ninja install -j $build_thread \
&& cd ../../ \
&& git clone --depth 1 https://github.com/coin-or/qpOASES.git \
&& mkdir qpOASES/build \
&& cd qpOASES/build \
&& cmake \
    -G Ninja \
    -DCMAKE_LINKER=/usr/local/libexec/mold/ld \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_CXX_FLAGS=-fPIC \
    -DQPOASES_BUILD_EXAMPLES=false \
    .. \
&& mold -run ninja install -j $build_thread \
&& cd ../../ \
&& git clone --depth 1 --recursive https://github.com/frankaemika/libfranka.git \
&& mkdir libfranka/build \
&& cd libfranka/build \
&& cmake \
    -G Ninja \
    -DCMAKE_LINKER=/usr/local/libexec/mold/ld \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_EXAMPLES=false \
    -DBUILD_TESTS=false \
    .. \
&& mold -run ninja install -j $build_thread \
&& cd ../../ \
&& cd ../ \
&& rm -rf install_from_sources \
&& apt-get remove --purge --yes \
    software-properties-common \
    gpg-agent \
    unzip \
    ninja-build \
    g++-11 \
    gcc-11 \
    stow \
|| exit 1
