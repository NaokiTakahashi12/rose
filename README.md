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
