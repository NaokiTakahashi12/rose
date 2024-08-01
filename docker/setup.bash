#!/bin/bash
. /opt/pylocal/bin/activate
. /opt/ros/${ROS_DISTRO}/setup.bash

if [ -f "${ROSE_WORKSPACE}/builtin/install/setup.bash" ] 
then
    . ${ROSE_WORKSPACE}/builtin/install/setup.bash
fi
if [ -f "${ROSE_WORKSPACE}/builtin/gz_sim/install/setup.bash" ] 
then
    . ${ROSE_WORKSPACE}/builtin/gz_sim/install/setup.bash
fi
if [ -f "${ROSE_WORKSPACE}/install/setup.bash" ] 
then
    . ${ROSE_WORKSPACE}/install/setup.bash
fi

if [ -z "$RMW_IMPLEMENTATION" ]
then
    export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
    if [ -f "${ROSE_WORKSPACE}/profiles/rmw_cyclonedds_profile.xml" ]
    then
        export CYCLONEDDS_URI=${ROSE_WORKSPACE}/profiles/rmw_cyclonedds_profile.xml
    fi
fi

if [ -z "$RCUTILS_COLORIZED_OUTPUT" ]
then
    export RCUTILS_COLORIZED_OUTPUT=1
fi
if [ -z "$ROS_DOMAIN_ID" ]
then
    export ROS_DOMAIN_ID=22
fi
if [ "$ROS_DISTRO" = "jazzy" ]
then
    if [ -z "$ROS_AUTOMATIC_DISCOVERY_RANGE" ]
    then
        export ROS_AUTOMATIC_DISCOVERY_RANGE=3
    fi
elif [ "$ROS_DISTRO" = "humble" ]
then
    if [ -z "$ROS_LOCALHOST_ONLY" ]
    then
        export ROS_LOCALHOST_ONLY=0
    fi
fi
