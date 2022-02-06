# Level 1

## Glossary:
- "image": a built set of instructions to start a container instance
- "base image": previously built image used as base for new image
- "docker cache": available in images to speed up building process
- "caching layer": for most image instructions a caching layer is created, which will be used in following build processes
- "container": an instance created from a docker image executing a given task


## Running a container with a pre-built image

### UNIX (x86 architecture) 
```shell
> docker run -it python:3.8
```
will launch a container with the image `ubuntu:latest`

### UNIX (ARM architecture)
Different host architectures require different image architectures.
Running given image on a RaspberryPi B+ v1.2 (from 2014) will not work out of the box, but it will tell us what went wrong
```shell
> docker run -it python:3.8
Unable to find image 'python:3.8' locally
3.8: Pulling from library/python
8b70a9729607: Pull complete
Digest: sha256:ba394fabd516b39ccf8597ec656a9ddd7d0a2688ed8cb373ca7ac9b6fe67848f
Status: Downloaded newer image from python:3.8
WARNING: The requested image's platform (linux/arm/v7) does not match the detected host platform (linux/arm/v6) and no specific platform was requested
```
You can look up specific base images for different architectures [here](https://github.com/docker-library/official-images#architectures-other-than-amd64).

To find the architecture used in your base system you can call
```shell
> uname -m
armv61
```
on UNIX devices.
For Windows devices this might require more work by the user, described [here](https://www.addictivetips.com/windows-tips/check-if-your-processor-is-32-bit-or-64-bit/).

So in order to start a python container we need to select an image from `arm32v6/`, specificly
```shell
> docker run -it arm32v6/python:3.8
```
### Windows
```shell
> docker run -it python:3.8
```

For more info, and how to use `docker` under Windows, see [ubuntu.com](https://ubuntu.com/tutorials/windows-ubuntu-hyperv-containers#1-overview)

**Note: Out of convenience, to not bloat the repository and because I simply can't test all things in all architectures
I decided to only use the common `x86` architecture in the following.**

# Dockerfiles
Dockerfile syntax ([reference](https://docs.docker.com/engine/reference/builder))
## Linux (Ubuntu)
An image that works as a host system [linux.Dockerfile](linux.Dockerfile):

```Dockerfile
FROM ubuntu:21.04
```

### Building the container
```shell
> docker build -f linux.Dockerfile -t custom-ubuntu:latest .
Sending build context to Docker daemon  13.82kB
Step 1/1 : FROM ubuntu:21.04
 ---> 7cc39f89fa58
Successfully built 7cc39f89fa58
Successfully tagged custom-ubuntu:latest
```
- `docker build` the command to build a docker image
- `-f linux.Dockerfile` the `Dockerfile` to use
- `-t custom-ubuntu:latest` gives the image a name and a tag with syntax `name:tag`
- `.` the context (the root directory available as `.` in the image file) to build the image in

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
    > docker run custom-ubuntu:latest whoami # displays current user, used in the running container
    root # this feels dangerous
    ```
    _Unfortunately a solution for this problem needs to be postponed and can be found in [level-3/django-postgres-docker-compose](../level-3/django-postgres-docker-compose)_  

    What damage could do this to the host?  
    Inspecting this further
    ```shell
    > docker run -it custom-ubuntu:latest bash
    root@6d67ddcb1626:/# lsblk -o NAME,SIZE,MOUNTPOINT,PATH
    NAME     SIZE MOUNTPOINT PATH
    sda    931.5G            /dev/sda
    |-sda1   300M            /dev/sda1
    `-sda2 931.2G            /dev/sda2  # <- this looks like the host fs, can we access it?

    root@6d67ddcb1626:/# ls -la /dev/sda
    ls: cannot access '/dev/sda': No such file or directory
  
    # looks like we can't access it, but why is it available
    # looking at mounted devices
    root@6d67ddcb1626:/# mount | grep "^/dev" 
    /dev/mapper/luks-dbdfb12b-35ea-454d-9d42-48ea05b993d8 on /etc/resolv.conf type ext4 (rw,noatime)
    /dev/mapper/luks-dbdfb12b-35ea-454d-9d42-48ea05b993d8 on /etc/hostname type ext4 (rw,noatime)
    /dev/mapper/luks-dbdfb12b-35ea-454d-9d42-48ea05b993d8 on /etc/hosts type ext4 (rw,noatime)
    ```
    **NEVER EXECUTE THE FOLLOWING ON YOUR OWN MACHINE!**
    ```shell
    # let's try deleting everything will this affect the host system?
    root@6d67ddcb1626:/# rm -rf --no-preserve-root /
    ```
    Running this command will delete all files we own as executing user. And because we're `root` at the moment
    this command will remove the content from within the container. Especially with mounted devices this can cause more damage
    than anticipated.  

### Modifying a running container and committing the progress

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
**Note: Keep the container running for the next step**

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
_Note: you can use either the `CONTAINER ID` or `NAMES` column to identify a container which is either running or stopped._
#### Extending the dockerfile
To for example keep the image up to date we can simplify the build process of an image by providing more statements in the dockerfile
```dockerfile
FROM ubuntu:21.04

RUN apt update      # update the local repositories
RUN apt upgrade -y  # upgrade all packages
```
#### Building the image
```shell
> docker buid -f linux-extended.Dockerfile -t linux-extended:latest .
Sending build context to Docker daemon  13.82kB
Step 1/3 : FROM ubuntu:21.04
 ---> 7cc39f89fa58
Step 2/3 : RUN apt update
 ---> Running in 35b1d16950f4
...
Removing intermediate container 35b1d16950f4
 ---> aa626393a128
Step 3/3 : RUN apt upgrade
 ---> Running in 85ae5bd63933
...
Removing intermediate container 85ae5bd63933
 ---> 39b6ef368110
Successfully built 39b6ef368110
Successfully tagged linux-extended:latest
```
As you can see each of the statements, each line, is called a `Step` in the ouput.
Each of the lines like
```text
---> 7cc39f89fa58
```
are hash values identifying caching layers. Those layers are used during the build process
and because of these layers, we can run 
```shell
> docker build -f linux-extended.Dockerfile -t linux-extended:latest . 
Sending build context to Docker daemon  14.85kB
Step 1/3 : FROM ubuntu:21.04
 ---> 7cc39f89fa58
Step 2/3 : RUN apt update
 ---> Using cache
 ---> aa626393a128
Step 3/3 : RUN apt upgrade
 ---> Using cache
 ---> 39b6ef368110
Successfully built 39b6ef368110
Successfully tagged linux-extended:latest
```
over and over again, and get immediate output stating which step used which existing cache layer.

For more info about the caching system see [the docs](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#leverage-build-cache).

To deactivate the caching system use `--no-cache`
```shell
> docker build --no-cache -f linux-extended.Dockerfile -t linux-extended:latest .
```
### Ubuntu + Python

[linux-python.Dockerfile](linux-python.Dockerfile): An image with a fixed pre-installed 
Python version.
```dockerfile
# Base image
FROM ubuntu:latest

# install interpreter
RUN apt update -y
RUN apt install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt update -y
RUN apt install -y python3.8
```
Installing a specific Python version in Ubuntu is unfortunately not that simple and this applies
to many other OS', in the next section we will learn about a solution to this problem, therefore I will
not explain every step in the dockerfile.

#### Build the image
```shell
docker build -f linux-python.Dockerfile -t ubuntu-python:latest .
```

Things to try:
- `docker run [image] -it --rm python3`
  - `--rm: Automatically remove the container when it exits`
- `docker run [image] --rm python3 -c "print('Hello World!')"`

### Python Interpreter
As previously mentioned, we don't need to always use `ubuntu` as a base image, there are plenty other ones to chose from,
and we can even use our own images to build new ones.  
[python.Dockerfile](python.Dockerfile): A prebuild image with a fixed python interpreter  

```dockerfile
FROM python:3.9
```

#### Build the image
```shell
docker build -f python.Dockerfile -t custom-python:latest . 
```

#### use the image
```shell
docker run -it custom-python:latest python
```

#### Providing a default command in the image file
```dockerfile
FROM python:3.9

CMD ["python3"]
```

#### using the image
```shell
docker build -f python-with-default-cmd.Dockerfile -t cmd-python:latest .
docker run -it cmd-python:latest
```

#### Alternative solution using a pre existing image
In case you just want to run a script within a container, consider something like
```shell
> docker run -v $PWD:/usr/app python:3.8 python /usr/app/script.py
This script is working.
```
More details about the additional arguments are given in [Level 2](../level-2).

## Summary
- Sometimes it's enough to use an existing image to work with and we don't need to create a new image for the task
- To predefine steps for a container we create a `Dockerfile`
- There are different base images we can choose from

## Additional infos
- You can look at the code 
  of the most common images at https://github.com/dockerfile, e.g. https://github.com/dockerfile/python/blob/master/Dockerfile
- some images are available with a `slim` tag, those use a different base image called `alpine`. Those images are magnitudes smaller and should be preferred in production environments.

## More Resources:
- free base files available for example at [hub.docker.com](https://hub.docker.com/)
- A list of resources for `docker`: https://github.com/veggiemonk/awesome-docker
