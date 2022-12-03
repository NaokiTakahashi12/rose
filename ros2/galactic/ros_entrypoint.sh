#!/bin/bash
set -e
[ -f /opt/ros/humble/setup.bash ] && source /opt/ros/humble/setup.bash
exec "$@"
