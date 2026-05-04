ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE} AS base

COPY ansible/inventory/localhost.yaml /ansible/inventory/localhost.yaml
COPY ansible/tasks/resolve_rose_context.yaml /ansible/tasks/resolve_rose_context.yaml
COPY ansible/playbooks/setup_base_common_tools.yaml /ansible/playbooks/setup_base_common_tools.yaml
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update --fix-missing \
    && apt-get install --yes --no-install-recommends \
        ca-certificates \
        python3-venv \
    && python3 -m venv /tmp/ansible \
    && /tmp/ansible/bin/python3 -m pip install --no-cache-dir \
        ansible \
    && /tmp/ansible/bin/ansible-playbook \
        --inventory /ansible/inventory/localhost.yaml \
        --connection local \
        /ansible/playbooks/setup_base_common_tools.yaml \
    && rm -rf /tmp/ansible \
    && apt-get purge --yes \
        python3-venv \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/*


FROM base AS ros2-base

ARG ROS_DISTRO=jazzy
ENV ROS_DISTRO=${ROS_DISTRO}

COPY ansible/playbooks/setup_ros_base.yaml /ansible/playbooks/setup_ros_base.yaml
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update --fix-missing \
    && apt-get install --yes --no-install-recommends \
        python3-venv \
    && python3 -m venv /tmp/ansible \
    && /tmp/ansible/bin/python3 -m pip install --no-cache-dir \
        ansible \
    && /tmp/ansible/bin/ansible-playbook \
        --inventory /ansible/inventory/localhost.yaml \
        --connection local \
        --extra-vars "rose_ros_distro=${ROS_DISTRO}" \
        /ansible/playbooks/setup_ros_base.yaml \
    && rm -rf /tmp/ansible \
    && apt-get purge --yes \
        python3-venv \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/*


FROM ros2-base AS rose-common

COPY ansible/playbooks/setup_rose_ros_common.yaml /ansible/playbooks/setup_rose_ros_common.yaml
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update --fix-missing \
    && apt-get install --yes --no-install-recommends \
        python3-venv \
    && python3 -m venv /tmp/ansible \
    && /tmp/ansible/bin/python3 -m pip install --no-cache-dir \
        ansible \
    && /tmp/ansible/bin/ansible-playbook \
        --inventory /ansible/inventory/localhost.yaml \
        --connection local \
        --extra-vars "rose_ros_distro=${ROS_DISTRO}" \
        /ansible/playbooks/setup_rose_ros_common.yaml \
    && rm -rf /tmp/ansible \
    && apt-get purge --yes \
        python3-venv \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/*

ARG ROSE_WORKSPACE=/rose/colcon_ws
ENV ROSE_WORKSPACE=${ROSE_WORKSPACE}


FROM rose-common AS rose-develop-common

COPY repos /ansible/repos
COPY ansible/requirements /ansible/requirements
COPY ansible/playbooks/setup_rose_ros_develop.yaml /ansible/playbooks/setup_rose_ros_develop.yaml
COPY ansible/playbooks/setup_rose_ros_simulator.yaml /ansible/playbooks/setup_rose_ros_simulator.yaml
COPY ansible/playbooks/setup_rose_ros_develop_builtin.yaml /ansible/playbooks/setup_rose_ros_develop_builtin.yaml
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update --fix-missing \
    && apt-get install --yes --no-install-recommends \
        python3-venv \
    && python3 -m venv /tmp/ansible \
    && /tmp/ansible/bin/python3 -m pip install --no-cache-dir \
        ansible \
    && /tmp/ansible/bin/ansible-playbook \
        --inventory /ansible/inventory/localhost.yaml \
        --connection local \
        --extra-vars "rose_ros_distro=${ROS_DISTRO}" \
        /ansible/playbooks/setup_rose_ros_develop.yaml \
    && rm -rf /tmp/ansible \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/*

ARG GZ_VERSION=harmonic
ENV GZ_VERSION=${GZ_VERSION}
ENV IGNITION_VERSION=${GZ_VERSION}

RUN export DEBIAN_FRONTEND=noninteractive \
    && python3 -m venv /tmp/ansible \
    && /tmp/ansible/bin/python3 -m pip install --no-cache-dir \
        ansible \
    && /tmp/ansible/bin/ansible-playbook \
        --inventory /ansible/inventory/localhost.yaml \
        --connection local \
        --extra-vars "rose_ros_distro=${ROS_DISTRO} rose_workspace=${ROSE_WORKSPACE} rose_gz_version=${GZ_VERSION} rose_repos_directory=/ansible/repos rose_cleanup_source_build_artifacts=true" \
        /ansible/playbooks/setup_rose_ros_simulator.yaml \
    && rm -rf /tmp/ansible \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /tmp/ansible \
    && /tmp/ansible/bin/python3 -m pip install --no-cache-dir \
        ansible \
    && /tmp/ansible/bin/ansible-playbook \
        --inventory /ansible/inventory/localhost.yaml \
        --connection local \
        --extra-vars "rose_ros_distro=${ROS_DISTRO} rose_workspace=${ROSE_WORKSPACE} rose_repos_directory=/ansible/repos rose_cleanup_source_build_artifacts=true" \
        /ansible/playbooks/setup_rose_ros_develop_builtin.yaml \
    && rm -rf /tmp/ansible


FROM rose-common AS rose-runtime

COPY profiles/rmw_cyclonedds_profile.xml ${ROSE_WORKSPACE}/profiles/rmw_cyclonedds_profile.xml
COPY setup.bash /setup.bash
COPY entrypoint.bash /entrypoint.sh
RUN rm -rf \
        /ansible \
        /opt/pylocal \
        /root/.cache \
        /tmp/*
ENTRYPOINT ["bash", "/entrypoint.sh"]
CMD ["/bin/bash"]


FROM rose-develop-common AS rose-develop

COPY profiles/rmw_cyclonedds_profile.xml ${ROSE_WORKSPACE}/profiles/rmw_cyclonedds_profile.xml
COPY colcon/defaults.yaml /root/.colcon/defaults.yaml
COPY setup.bash /setup.bash
COPY entrypoint.bash /entrypoint.sh
RUN echo ". /setup.bash" >> ~/.bashrc
RUN rm -rf \
        /ansible \
        /root/.cache \
        /tmp/*
WORKDIR ${ROSE_WORKSPACE}
ENTRYPOINT ["bash", "/entrypoint.sh"]
SHELL ["/bin/bash", "-c"]
CMD ["/bin/bash"]
