# Level 1
Dockerfile syntax ([reference](https://docs.docker.com/engine/reference/builder))

## Linux (Ubuntu)
An image that works as a host system [linux.Dockerfile](linux.Dockerfile):

```Dockerfile
FROM ubuntu:21.04
```

### Building the container
```shell
docker build -f linux.Dockerfile -t custom-ubuntu:latest .
```
- `docker build` the command to build a docker image
- `-f linux.Dockerfile` the `Dockerfile` to use
- `-t custom-ubuntu:latest` gives the image a name and a tag with syntax `name:tag`


### Running a task using an image 

- `docker run -it custom-ubuntu:latest bash`
  - `docker run` the command to run a task in a container, created by the provided image
  - `-it` run in interactive mode
  - `custom-ubuntu:latest` the image name to create a container from
  - `bash` the command to run in the interactive container
- 
  ```shell
  > docker run custom-ubuntu:latest du -hcs # displays overall size of filesystem
  du: cannot access './proc/1/task/1/fd/4': No such file or directory
  du: cannot access './proc/1/task/1/fdinfo/4': No such file or directory
  du: cannot access './proc/1/fd/3': No such file or directory
  du: cannot access './proc/1/fdinfo/3': No such file or directory
  86M	.
  86M	total

  ```
- 
  ```shell
  > docker run custom-ubuntu:latest lsblk # displays available and mounted storage
    NAME                                          MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
  sda                                             8:0    0 931,5G  0 disk  
  ├─sda1                                          8:1    0   300M  0 part  /boot/efi
  └─sda2                                          8:2    0 931,2G  0 part  
    └─luks-dbdfb12b-35ea-454d-9d42-48ea05b993d8 254:0    0 931,2G  0 crypt /
  ```
- 
  ```shell
  > docker run custom-ubuntu:latest whoami # displays current user, used in the running container
  root
  ```
### Modifying a running container and commiting the progress

#### modifying an image
```shell
> docker run -it custom-ubuntu:latest bash # start a container with the base image and run a bash shell in it
root@e78d0e6b4f1e:/# apt update # update the system
...
root@e78d0e6b4f1e:/# apt install python3 # install the python 3 interpreter provided by the distribution repositories
...
root@e78d0e6b4f1e:/# python3 --version
Python 3.9.5
```
**Note: Keep the container running**

#### Saving the progress

On the host machine:
```shell
> docker ps
CONTAINER ID   IMAGE                  COMMAND   CREATED          STATUS          PORTS     NAMES
0dc20bf1cb7a   custom-ubuntu:latest   "bash"    51 seconds ago   Up 50 seconds             wizardly_chatterjee
> docker commit 0dc20bf1cb7a 
sha256:ec71409492a78239c26e38b67191364c486da3543d6a6e38327d50aa7319c1a3
> docker tag ec71409492a78239c26e38b67191364c486da3543d6a6e38327d50aa7319c1a3 custom-ubuntu-python:latest
> docker run custom-ubuntu-python:latest python3 --version
Python 3.9.5
```

## More Dockefiles
### Ubuntu + Python

[linux-python.Dockerfile](linux-python.Dockerfile): An image with a fixed pre-installed 
Python version.

Things to try:
- `docker run [image] -it --rm python3`
  - `--rm: Automatically remove the container when it exits`
- `docker run [image] --rm python3 -c "print('Hello World!')"`

## Python
[python.Dockerfile](python.Dockerfile): A prebuild image with a fixed python interpreter  


## More Resources:
- free base files available for example at [hub.docker.com](https://hub.docker.com/)
- A list of resources for `docker`: https://github.com/veggiemonk/awesome-docker
