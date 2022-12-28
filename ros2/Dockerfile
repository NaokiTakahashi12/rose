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

RUN apt-get update --quiet \
    && apt-get upgrade --quiet --yes \
    && sh rose/setup/install_base_dependent_libraries.sh \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY scripts/install_ros2.sh /rose/setup/

RUN sh rose/setup/install_ros2.sh \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

FROM base AS runtime

COPY repos/preinstall_${ROS_DISTRO}.yaml /rose/setup/
COPY scripts/build_install_packages.sh /rose/setup/

RUN sh rose/setup/build_install_packages.sh \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY bash_entrypoint.bash /bash_entrypoint.bash
COPY ros_entrypoint.sh /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]

RUN echo "[ -f /bash_entrypoint.bash ] && source /bash_entrypoint.bash" >> /root/.bashrc

CMD ["bash"]

FROM runtime AS develop

ARG IGNITION_VERSION=fortress

ENV IGNITION_VERSION=${IGNITION_VERSION}
ENV GZ_VERSION=${IGNITION_VERSION}

COPY scripts/install_ignition_gazebo.sh /rose/setup/

RUN sh rose/setup/install_ignition_gazebo.sh \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY repos/preinstall_develop_${ROS_DISTRO}.yaml /rose/setup/
COPY scripts/install_developer_tools.sh /rose/setup/

RUN sh rose/setup/install_developer_tools.sh \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "[safe]" >> ~/.gitconfig \
    && echo "    directory = *" >> ~/.gitconfig

CMD ["bash"]
