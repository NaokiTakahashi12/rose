#!/bin/bash
if [ -z "${ROSE_PYTHON_TOOLS_VENV}" ]
then
    if [ "$(id -u)" = "0" ]
    then
        ROSE_PYTHON_TOOLS_VENV=/opt/pylocal
    else
        ROSE_PYTHON_TOOLS_VENV="${HOME}/.local/share/rose/pylocal"
    fi
fi
export ROSE_PYTHON_TOOLS_VENV

if [ -z "${ROSE_WORKSPACE}" ]
then
    if [ "$(id -u)" = "0" ]
    then
        ROSE_WORKSPACE=/rose/colcon_ws
    else
        ROSE_WORKSPACE="${HOME}/rose/colcon_ws"
    fi
fi
export ROSE_WORKSPACE

if [ -f "${ROSE_PYTHON_TOOLS_VENV}/bin/activate" ]
then
    . "${ROSE_PYTHON_TOOLS_VENV}/bin/activate"
fi
. "/opt/ros/${ROS_DISTRO}/setup.bash"

if [ -f "${ROSE_WORKSPACE}/builtin/install/setup.bash" ]
then
    . "${ROSE_WORKSPACE}/builtin/install/setup.bash"
fi
if [ -f "${ROSE_WORKSPACE}/builtin/gz_sim/install/setup.bash" ]
then
    . "${ROSE_WORKSPACE}/builtin/gz_sim/install/setup.bash"
fi
if [ -f "${ROSE_WORKSPACE}/install/setup.bash" ]
then
    . "${ROSE_WORKSPACE}/install/setup.bash"
fi

if [ -z "$RMW_IMPLEMENTATION" ]
then
    export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
    if [ -f "${ROSE_WORKSPACE}/profiles/rmw_cyclonedds_profile.xml" ]
    then
        export CYCLONEDDS_URI="${ROSE_WORKSPACE}/profiles/rmw_cyclonedds_profile.xml"
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
