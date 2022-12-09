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
    exit 1
else
    echo "ROS_DISTRO is ${ROS_DISTRO}"
fi

repos_file=/rose/setup/preinstall_${ROS_DISTRO}.yaml

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

distoribution_unique_package=""

if [ "${ROS_DISTRO}" = "humble" ]
then
    distoribution_unique_package="
        ros-${ROS_DISTRO}-rcpputils \
        ros-${ROS_DISTRO}-nlohmann-json-schema-validator-vendor \
        ros-${ROS_DISTRO}-generate-parameter-library \
        ros-${ROS_DISTRO}-rsl
    "
else
    distoribution_unique_package="
        ros-${ROS_DISTRO}-robot-localization
    "
fi

export DEBIAN_FRONTEND=noninteractive \
&& export CC=gcc-11 \
&& export CXX=g++-11 \
&& apt-get update --quiet --fix-missing \
&& apt-get install --yes --quiet --no-install-recommends \
    gcc-11 \
    g++-11 \
    python3-vcstool \
    python3-colcon-common-extensions \
    libpcl-dev \
    liboctomap-dev \
    nlohmann-json3-dev \
    $distoribution_unique_package \
    ros-${ROS_DISTRO}-ament-cmake \
    ros-${ROS_DISTRO}-test-msgs \
    ros-${ROS_DISTRO}-map-msgs \
    ros-${ROS_DISTRO}-octomap-msgs \
    ros-${ROS_DISTRO}-ackermann-msgs \
    ros-${ROS_DISTRO}-geographic-msgs \
    ros-${ROS_DISTRO}-diagnostic-updater \
    ros-${ROS_DISTRO}-rviz-common \
    ros-${ROS_DISTRO}-rviz-default-plugins \
    ros-${ROS_DISTRO}-joy \
    ros-${ROS_DISTRO}-teleop-tools \
    ros-${ROS_DISTRO}-joy-teleop \
    ros-${ROS_DISTRO}-teleop-twist-joy \
    ros-${ROS_DISTRO}-teleop-twist-keyboard \
&& mkdir -p preinstall_ws/src \
&& cd preinstall_ws/ \
&& vcs import src < $repos_file \
    --recursive \
&& colcon build \
    --merge-install \
    --executor sequential \
    --parallel-workers $build_thread \
    --install-base /opt/ros_buildin/${ROS_DISTRO} \
    --cmake-args \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_STANDARD_LIBRARIES="-lpthread" \
        -DCMAKE_SHARED_LINKER_FLAGS="-lpthread" \
        -DBUILD_TESTING=false \
        -DCMAKE_POSITION_INDEPENDENT_CODE=true \
    --packages-ignore \
        nav2_system_tests \
        test_bond \
&& cd ../ \
&& rm -rf preinstall_ws \
&& apt-get remove ---purge --yes \
    gcc-11 \
    g++-11 \
    python3-vcstool \
    python3-colcon-common-extensions \
|| exit 1
