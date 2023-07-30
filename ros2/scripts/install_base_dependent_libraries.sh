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

# To avoid Jetson /tmp/apt-dpkg-install-cLwPHV/261-libopencv-dev_4.5.4-8-g3e4c170df4_arm64.deb
if ! apt list --installed | grep -q libopencv-dev
then
    export DEBIAN_FRONTEND=noninteractive \
    && apt-get update --quiet \
    && apt-get install --yes --quiet --no-install-recommends \
        libopencv-dev
fi

CUDA_SUPPORT="false"
if type "nvcc" > /dev/null 2>&1
then
    CUDA_SUPPORT="true"
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
    ansible \
    ca-certificates \
    libboost-all-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libboost-serialization-dev \
    libboost-thread-dev \
    libboost-timer-dev \
    libboost-chrono-dev \
    libboost-regex-dev \
    libboost-date-time-dev \
    libboost-iostreams-dev \
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
    libboost-all-dev \
    libeigen3-dev \
    libvtk7-dev \
    libqhull-dev \
    libopenni-dev \
    libopenni2-dev \
    nlohmann-json3-dev \
    libtbb-dev \
    liblz4-dev \
&& mkdir install_from_sources \
&& cd install_from_sources/ \
&& git clone https://github.com/rui314/mold.git \
    --depth 1 \
    --branch v2.0.0 \
&& cd mold/ \
&& cmake \
    -S . \
    -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
&& cmake --build build -j $build_thread \
&& cmake --install build \
&& cd ../ \
&& git clone https://github.com/flann-lib/flann.git \
    --depth 1 \
    --branch 1.9.2 \
&& cd flann/ \
&& cmake \
    -S . \
    -B build \
    -G Ninja \
    -DBUILD_CUDA_LIB="$CUDA_SUPPORT" \
    -DCUDA_SDK_ROOT_DIR=/usr/local/cuda \
    -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
    -DNVCC_COMPILER_BINDIR=/usr/bin \
    -DBUILD_EXAMPLES=false \
    -DBUILD_DOC=false \
    -DBUILD_TESTS=false \
    -DCMAKE_BUILD_TYPE=Release \
&& VERBOSE=1 cmake --build build -j 1 \
&& cmake --install build \
&& cd ../ \
&& git clone https://github.com/PointCloudLibrary/pcl.git \
    --depth 1 \
    --branch pcl-1.12.1 \
&& cd pcl/ \
&& cmake \
    -S . \
    -B build \
    -G Ninja \
    -DCMAKE_LINKER=/usr/local/libexec/mold/ld \
    -DBUILD_GPU="$CUDA_SUPPORT" \
    -DWITH_CUDA="$CUDA_SUPPORT" \
    -DBUILD_CUDA="$CUDA_SUPPORT" \
    -DBUILD_gpu_kinfu_large_scale_to=false \
    -DBUILD_gpu_kinfu_large_scale=false \
    -DBUILD_gpu_kinfu_tools=false \
    -DBUILD_gpu_kinfu=false \
    -DCMAKE_BUILD_TYPE=Release \
&& mold -run cmake --build build -j $build_thread \
&& cmake --install build \
&& cd ../ \
&& git clone https://github.com/IntelRealSense/librealsense.git \
    --depth 1 \
    --branch development \
&& cd librealsense/ \
&& cmake \
    -S . \
    -B build \
    -G Ninja \
    -DCMAKE_LINKER=/usr/local/libexec/mold/ld \
    -DBUILD_EXAMPLES=false \
    -DGLFW_BUILD_EXAMPLES=false \
    -DBUILD_GRAPHICAL_EXAMPLES=false \
    -DBUILD_PCL_EXAMPLES=false \
    -DBUILD_WITH_CUDA="$CUDA_SUPPORT" \
    -DBUILD_WITH_OPENMP=true \
    -DCMAKE_BUILD_TYPE=Release \
&& mold -run cmake --build build -j $build_thread \
&& cmake --install build \
&& cd ../ \
&& git clone https://github.com/borglab/gtsam.git \
    -b 4.1.1 \
    --depth 1 \
&& cd gtsam/ \
&& cmake \
    -S . \
    -B build \
    -DGTSAM_USE_SYSTEM_EIGEN=true \
    -DGTSAM_BUILD_WITH_MARCH_NATIVE=false \
    -DGTSAM_BUILD_EXAMPLES_ALWAYS=false \
    -DGTSAM_BUILD_TESTS=false \
    -DCMAKE_BUILD_TYPE=Release \
&& cmake --build build -j $build_thread \
&& cmake --install build \
&& cd ../ \
&& git clone https://github.com/rbdl/rbdl.git \
    --depth 1 \
    --recursive \
    --branch v3.2.1 \
&& cd rbdl/ \
&& cmake \
    -S . \
    -B build \
    -G Ninja \
    -DCMAKE_LINKER=/usr/local/libexec/mold/ld \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=true \
    -DRBDL_BUILD_ADDON_URDFREADER=true \
    -DRBDL_BUILD_ADDON_GEOMETRY=true \
&& mold -run cmake --build build -j $build_thread \
&& cmake --install build \
&& cd ../ \
&& git clone https://github.com/coin-or/qpOASES.git \
    --depth 1 \
&& cd qpOASES/ \
&& cmake \
    -S . \
    -B build \
    -G Ninja \
    -DCMAKE_LINKER=/usr/local/libexec/mold/ld \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_CXX_FLAGS=-fPIC \
    -DQPOASES_BUILD_EXAMPLES=false \
&& mold -run cmake --build build -j $build_thread \
&& cmake --install build \
&& cd ../ \
&& git clone https://github.com/frankaemika/libfranka.git \
    --depth 1 \
    --recursive \
&& cd libfranka/ \
&& cmake \
    -S . \
    -B build \
    -G Ninja \
    -DCMAKE_LINKER=/usr/local/libexec/mold/ld \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_EXAMPLES=false \
    -DBUILD_TESTS=false \
&& mold -run cmake --build build -j $build_thread \
&& cmake --install build \
&& cd ../ \
&& git clone https://github.com/xtensor-stack/xtl.git \
    --depth 1 \
&& cd xtl/ \
&& cmake \
    -S . \
    -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
&& mold -run cmake --build build -j $build_thread \
&& cmake --install build \
&& cd ../ \
&& git clone https://github.com/xtensor-stack/xtensor.git \
    --depth 1 \
&& cd xtensor/ \
&& cmake \
    -S . \
    -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
&& mold -run cmake --build build -j $build_thread \
&& cmake --install build \
&& cd ../ \
&& git clone https://github.com/xtensor-stack/xsimd.git \
    --depth 1 \
&& cd xsimd/ \
&& cmake \
    -S . \
    -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
&& mold -run cmake --build build -j $build_thread \
&& cmake --install build \
&& cd ../ \
&& git clone https://github.com/NaokiTakahashi12/unitree_legged_sdk.git \
    --depth 1 \
    -b go1-latest \
&& cd unitree_legged_sdk/ \
&& cmake \
    -S . \
    -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
&& mold -run cmake --build build -j $build_thread \
&& cmake --install build \
&& cd ../ \
&& cd ../ \
&& rm -rf install_from_sources \
&& apt-get remove --purge --yes \
    software-properties-common \
    gpg-agent \
    unzip \
    ninja-build \
    stow \
|| exit 1
