# rose

My ROS Enviroments

## Usage

Startup

```shell
source scripts/setup.bash
rose up
rose exec -s galactic
```

`rose`sub-commands

```shell
rose help
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
