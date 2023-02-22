#!/bin/bash
[ -f /opt/gz/$IGNITION_VERSION/setup.bash ] && source /opt/gz/$IGNITION_VERSION/setup.bash
[ -f /opt/ros/$ROS_DISTRO/setup.bash ] && source /opt/ros/$ROS_DISTRO/setup.bash
[ -f /opt/ros_buildin/$ROS_DISTRO/setup.bash ] && source /opt/ros_buildin/$ROS_DISTRO/setup.bash
[ -f /opt/ros_devel_buildin/$ROS_DISTRO/setup.bash ] && source /opt/ros_devel_buildin/$ROS_DISTRO/setup.bash
[ -f /rose/colcon_ws/install/setup.bash ] && source /rose/colcon_ws/install/setup.bash
if [ -d /usr/local/lib/rust ]
then
    export PATH=$PATH:$CARGO_HOME/bin
fi
