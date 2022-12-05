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

# TODO argument of rosdistro

if [ -z "${ROS_DISTRO}" ]
then
    echo "Empty ROS_DISTRO variable"
    return 2
else
    echo "ROS_DISTRO is ${ROS_DISTRO}"
fi

export DEBIAN_FRONTEND=noninteractive \
&& apt-get update --quiet --fix-missing \
&& apt-get install --yes --quiet --no-install-recommends \
    vim \
    git \
    cmake \
    gcc \
    g++ \
    silversearcher-ag \
    python3-pip \
    python3-vcstool \
    python3-colcon-common-extensions \
    python3-colcon-argcomplete \
    python3-colcon-cd \
    python3-colcon-cmake \
    python3-colcon-pkg-config \
    python3-colcon-ros \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-rviz-imu-plugin \
    ros-${ROS_DISTRO}-octomap-rviz-plugins \
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
|| exit 1
