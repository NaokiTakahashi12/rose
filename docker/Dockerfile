ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE} AS base

RUN export DEBIANFRONTEND=nointeractive \
    && apt-get update --fix-missing \
    && apt-get install --yes --no-install-recommends \
        python3-venv \
    && python3 -m venv /opt/pylocal \
    && . /opt/pylocal/bin/activate \
    && python3 -m pip install --no-cache-dir \
        ansible \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/*

COPY ansible/inventory/localhost.yaml /ansible/inventory/localhost.yaml
COPY ansible/playbooks/setup_base_common_tools.yaml /ansible/playbooks/setup_base_common_tools.yaml
RUN export DEBIANFRONTEND=nointeractive \
    && . /opt/pylocal/bin/activate \
    && apt-get update --fix-missing \
    && ansible-playbook \
        --inventory /ansible/inventory/localhost.yaml \
        --connection local \
        /ansible/playbooks/setup_base_common_tools.yaml \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/*


FROM base AS ros2-base

ARG ROS_DISTRO=jazzy
ENV ROS_DISTRO=${ROS_DISTRO}

COPY ansible/playbooks/setup_ros_base.yaml /ansible/playbooks/setup_ros_base.yaml
RUN export DEBIANFRONTEND=nointeractive \
    && . /opt/pylocal/bin/activate \
    && apt-get update --fix-missing \
    && ansible-playbook \
        --inventory /ansible/inventory/localhost.yaml \
        --connection local \
        /ansible/playbooks/setup_ros_base.yaml \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/*


FROM ros2-base AS rose-common

COPY ansible/playbooks/setup_rose_ros_common.yaml /ansible/playbooks/setup_rose_ros_common.yaml
RUN export DEBIANFRONTEND=nointeractive \
    && . /opt/pylocal/bin/activate \
    && apt-get update --fix-missing \
    && ansible-playbook \
        --inventory /ansible/inventory/localhost.yaml \
        --connection local \
        /ansible/playbooks/setup_rose_ros_common.yaml \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/*

ARG ROSE_WORKSPACE=/rose/colcon_ws
ENV ROSE_WORKSPACE=${ROSE_WORKSPACE}


FROM rose-common AS rose-develop-common

COPY ansible/playbooks/setup_rose_ros_develop.yaml /ansible/playbooks/setup_rose_ros_develop.yaml
RUN export DEBIANFRONTEND=nointeractive \
    && . /opt/pylocal/bin/activate \
    && apt-get update --fix-missing \
    && ansible-playbook \
        --inventory /ansible/inventory/localhost.yaml \
        --connection local \
        /ansible/playbooks/setup_rose_ros_develop.yaml \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/*

ARG GZ_VERSION=harmonic
ENV GZ_VERSION=${GZ_VERSION}
ENV IGNITION_VERSION=${GZ_VERSION}

COPY repos/gz_sim_${ROS_DISTRO}_builtin.yaml /${ROSE_WORKSPACE}/repos/gz_sim_builtin.yaml
COPY ansible/playbooks/setup_rose_ros_simulator.yaml /ansible/playbooks/setup_rose_ros_simulator.yaml
RUN export DEBIANFRONTEND=nointeractive \
    && . /opt/pylocal/bin/activate \
    && apt-get update --fix-missing \
    && ansible-playbook \
        --inventory /ansible/inventory/localhost.yaml \
        --connection local \
        /ansible/playbooks/setup_rose_ros_simulator.yaml \
    && rm -rf \
        ${ROSE_WORKSPACE}/builtin/gz_sim/src \
        ${ROSE_WORKSPACE}/builtin/gz_sim/log \
        ${ROSE_WORKSPACE}/builtin/gz_sim/build \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/*

COPY repos/develop_builtin.yaml ${ROSE_WORKSPACE}/repos/develop_builtin.yaml
COPY repos/develop_builtin_${ROS_DISTRO}.yaml ${ROSE_WORKSPACE}/repos/develop_builtin_${ROS_DISTRO}.yaml
COPY ansible/playbooks/setup_rose_ros_develop_builtin.yaml /ansible/playbooks/setup_rose_ros_develop_builtin.yaml
RUN . /opt/pylocal/bin/activate \
    && ansible-playbook \
        --inventory /ansible/inventory/localhost.yaml \
        --connection local \
        /ansible/playbooks/setup_rose_ros_develop_builtin.yaml \
    && rm -rf \
        ${ROSE_WORKSPACE}/builtin/src \
        ${ROSE_WORKSPACE}/builtin/log \
        ${ROSE_WORKSPACE}/builtin/build


FROM rose-common AS rose-runtime

COPY profiles/rmw_cyclonedds_profile.xml ${ROSE_WORKSPACE}/profiles/rmw_cyclonedds_profile.xml
COPY setup.bash /setup.bash
COPY entrypoint.bash /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]
HEALTHCHECK --interval=30s --timeout=4s CMD bash -c ". /setup.bash; ros2 topic list --include-hidden-topics -c"
CMD ["/bin/bash"]


FROM rose-develop-common AS rose-develop

COPY profiles/rmw_cyclonedds_profile.xml ${ROSE_WORKSPACE}/profiles/rmw_cyclonedds_profile.xml
COPY colcon/defaults.yaml /root/.colcon/defaults.yaml
COPY setup.bash /setup.bash
COPY entrypoint.bash /entrypoint.sh
RUN echo ". /setup.bash" >> ~/.bashrc
WORKDIR ${ROSE_WORKSPACE}
ENTRYPOINT ["bash", "/entrypoint.sh"]
SHELL ["/bin/bash", "-c"]
HEALTHCHECK --interval=30s --timeout=4s CMD bash -c ". /setup.bash; ros2 topic list --include-hidden-topics -c"
CMD ["/bin/bash"]


