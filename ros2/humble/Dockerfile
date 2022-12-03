ARG BASE_IMAGE=ros:humble

FROM ${BASE_IMAGE} AS base

ARG GIT_ORIGIN=unkown
ARG GIT_REVISION=unkown
LABEL git.origin=${GIT_ORIGIN}
LABEL git.revision=${GIT_REVISION}

ARG ROS_DISTRO=humble
LABEL ros.distro=${ROS_DISTRO}
ENV ROS_DISTRO=${ROS_DISTRO}

COPY scripts/install_base_dependent_libraries.sh /rose/setup/

RUN sh rose/setup/install_base_dependent_libraries.sh \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY scripts/install_ros2.sh /rose/setup/

RUN sh rose/setup/install_ros2.sh \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM base AS runtime

COPY ros_entrypoint.sh /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]

CMD ["bash"]

FROM runtime AS develop

ARG IGNITION_VERSION=fortress
# TODO
#ARG IGNITION_VERSION=garden

ENV IGNITION_VERSION=${IGNITION_VERSION}
ENV GZ_VERSION=${IGNITION_VERSION}

COPY scripts/install_ignition_gazebo.sh /rose/setup/

RUN sh rose/setup/install_ignition_gazebo.sh \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
