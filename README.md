# rose

My ROS Enviroments


## Usage

Startup

```shell
$ source scripts/setup.bash
$ rose up
$ rose exec -s galactic
```

or

```shell
$ docker compose up -d
$ docker compose exec galactic bash
```

## Support ros2 distribution

The ros2 distribution currently supported by rose are

+ humble
+ galactic (CUDA)


## Local workspace

The development workspace mounted on the container has the following relationship.

+ workspace/humble -> humble:/rose/colcon_ws
+ workspace/galactic -> galactic:/rose/colcon_ws


## Requirements

### Dependencies

- [docker](https://docs.docker.com/get-docker/) >= 19.03.4
- [docker compose v2](https://docs.docker.com/compose/compose-v2/)
- X11 (optional)
- python >= 3.10 (optional)


### System Resource

- Storage >= 20[GB]


## ROSE CLI tools

`rose`sub-commands

```shell
$ rose help
usage: rose [-h] {help,version,get-compose-prefix,ps,ls,logs,pull,exec,up,down,build} ...

ROS Enviroment operation tools

positional arguments:
  {help,version,get-compose-prefix,ps,ls,logs,pull,exec,up,down,build}
                        ROS Enviroment sub-commands
    help                Show the ROSE help infomation.
    version             Show the ROSE version infomation.
    get-compose-prefix  Get execute command prefix.
    ps                  Show constainer process status.
    ls                  List running compose containers.
    logs                View output log from container.
    pull                Pull ROSE service images.
    exec                Execute a bash command in a running container.
    up                  Create and start services.
    down                Stop and remove services.
    build               Build or rebuild services.

options:
  -h, --help            show this help message and exit
```


## Operational Strategies

Tags are divided into "runtime" tags and "develop" tags, each with the following meanings

- A runtime tag is an environment to deploy to a robot.
- A development-time tag is an environment that includes a simulator to be developed before deploying to a robot.


## Installed ros2 packages

+ [humble develop](docs/installed_packages/humble_develop.txt)
+ [humble runtime](docs/installed_packages/humble_runtime.txt)
+ [galactic develop](docs/installed_packages/galactic_develop.txt)
+ [galactic runtime](docs/installed_packages/galactic_runtime.txt)
