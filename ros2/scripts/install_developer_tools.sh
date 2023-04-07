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

# TODO argument of rosdistro
if [ -z "${ROS_DISTRO}" ]
then
    echo "Empty ROS_DISTRO variable"
    exit 1
else
    echo "ROS_DISTRO is ${ROS_DISTRO}"
fi

repos_file=/rose/setup/preinstall_develop_${ROS_DISTRO}.yaml

if [ ! -f $repos_file ]
then
    exit 1
fi

build_thread=$((`nproc`/2))

if [ 0 -eq $build_thread ]
then
    build_thread=1
fi

if [ -f /opt/ros/${ROS_DISTRO}/setup.sh ]
then
    . /opt/ros/${ROS_DISTRO}/setup.sh
fi
if [ -f /opt/gz/${IGNITION_VERSION}/setup.sh ]
then
    . /opt/gz/${IGNITION_VERSION}/setup.sh
fi
if [ -f /opt/ros_buildin/${ROS_DISTRO}/setup.sh ]
then
    . /opt/ros_buildin/${ROS_DISTRO}/setup.sh
fi

build_ignore_packages="
        champ_gazebo \
"

if [ "${ROS_DISTRO}" = "humble" ]
then
    build_ignore_packages="
        $build_ignore_packages \
    "
else
    build_ignore_packages="
        $build_ignore_packages \
        unitree_go1_bridge \
    "
fi

export DEBIAN_FRONTEND=noninteractive \
export RTI_NC_LICENSE_ACCEPTED=yes \
&& apt-get update --quiet --fix-missing \
&& apt-get install --yes --quiet --no-install-recommends \
    curl \
    vim \
    git \
    make \
    cmake \
    cmake-curses-gui \
    gcc \
    g++ \
    tmux \
    fzf \
    silversearcher-ag \
    libcairo-dev \
    python3-pip \
    python3-vcstool \
    python3-colcon-common-extensions \
    python3-colcon-argcomplete \
    python3-colcon-cd \
    python3-colcon-cmake \
    python3-colcon-pkg-config \
    python3-colcon-ros \
    ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
    ros-${ROS_DISTRO}-rmw-connextdds \
    ros-${ROS_DISTRO}-turtlebot3-description \
    ros-${ROS_DISTRO}-moveit-resources-panda-description \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-rviz-imu-plugin \
    ros-${ROS_DISTRO}-octomap-rviz-plugins \
    ros-${ROS_DISTRO}-plansys2-tools \
    ros-${ROS_DISTRO}-rmf-visualization-rviz2-plugins \
    ros-${ROS_DISTRO}-rqt-image-view \
    ros-${ROS_DISTRO}-rqt-image-overlay \
    ros-${ROS_DISTRO}-rqt-image-overlay-layer \
    ros-${ROS_DISTRO}-rqt-plot \
    ros-${ROS_DISTRO}-rqt-reconfigure \
    ros-${ROS_DISTRO}-rqt-robot-dashboard \
    ros-${ROS_DISTRO}-rqt-robot-monitor \
    ros-${ROS_DISTRO}-rqt-runtime-monitor \
    ros-${ROS_DISTRO}-ament-cmake-copyright \
    ros-${ROS_DISTRO}-ament-clang-tidy \
    ros-${ROS_DISTRO}-ament-clang-format \
    ros-${ROS_DISTRO}-ament-mypy \
    ros-${ROS_DISTRO}-ament-xmllint \
&& mkdir install_from_sources \
&& cd install_from_sources/ \
&& git clone https://github.com/abseil/abseil-cpp.git \
&& cd abseil-cpp/ \
&& git checkout 2151058 \
&& cmake \
    -S . \
    -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=true \
    -Dprotobuf_BUILD_TESTS=false \
&& cmake --build build -j $build_thread \
&& cmake --install build \
&& cd .. \
&& cd .. \
&& rm -rf install_from_sources \
&& mkdir -p preinstall_ws/src \
&& cd preinstall_ws/ \
&& vcs import src < $repos_file \
    --recursive \
&& colcon build \
    --merge-install \
    --executor sequential \
    --parallel-workers $build_thread \
    --install-base /opt/ros_devel_buildin/${ROS_DISTRO} \
    --cmake-args \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_STANDARD_LIBRARIES="-lpthread" \
        -DCMAKE_SHARED_LINKER_FLAGS="-lpthread" \
        -DBUILD_TESTING=false \
        -DCMAKE_POSITION_INDEPENDENT_CODE=true \
    --packages-ignore \
        $build_ignore_packages \
&& cd ../ \
&& rm -rf preinstall_ws \
|| exit 1

export RUST_HOME=/usr/local/lib/rust \
&& export RUSTUP_HOME=$RUST_HOME/rustup \
&& export CARGO_HOME=$RUST_HOME/cargo \
&& mkdir /usr/local/lib/rust \
&& curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rustup.sh \
&& sh /tmp/rustup.sh -y \
&& . /usr/local/lib/rust/cargo/env \
&& cargo install \
    zoxide \
|| exit 1
