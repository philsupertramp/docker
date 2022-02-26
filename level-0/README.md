# Installation
For official instructions consult [Get Docker](https://docs.docker.com/get-docker/).

This section will sumarize the installation process, in case of issues consult the official documentation first.

## Linux
### Docker installation
#### Ubuntu

Install required packages
```shell
> sudo apt-get update
> sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

[optional] Obtain used GPG key
```shell
>  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
[optional] Verify GPG key
```shell
> echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
Install docker
```shell
> sudo apt-get update
> sudo apt-get install docker-ce docker-ce-cli containerd.io
```

#### Debian
Install dependencies
```shell
> sudo apt-get update
> sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```
[optional] Get the signed key for the package
```shell
> curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
[optional] Verify the key
```shell
> echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
Install docker
```shell
> sudo apt-get update
> sudo apt-get install docker-ce docker-ce-cli containerd.io
```

#### CentOS

Install required packages and add the docker repository
```shell
> sudo yum install -y yum-utils
> sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```
Install docker
```shell
> sudo yum install docker-ce docker-ce-cli containerd.io
```

#### Arch

```shell
$ pacman -S docker
```

### Required steps after installation
Generate a user group, if not existing
```shell
$ groupadd docker
```
Assign the user `[username]` to the new group
```shell
$ usermod -aG [username] docker
```

Reboot your machine to enable `docker`.


Verify the installation for your user using
```shell
> docker info
```

## MacOS
For MacOS installation please consult the [docs](https://docs.docker.com/desktop/mac/install/).  
**Note the installation differs for Apple Silicon and Intel processors.**

## Windows
For Windows installation please also consult the official [docs](https://docs.docker.com/desktop/windows/install/) page.

A few notes along the way:
1. Read the description thoroughly
2. To run regular `x86` architecture images on windows [WSL 2](https://docs.microsoft.com/en-us/windows/wsl/install) is required  
3. To use `docker` under Windows BIOS-level hardware virtualization support must be enabled in the BIOS settings


# Use cases
- Resolves issues like "It works on my machine" through containerization
- Simplifies dependency management, one system to maintain, not individually maintain every development installation
- dependencies of host system get maintained by image publisher
- Simplify onboarding processes of new team members
- Simplifies hosting in a production environment by releasing a new image, e.g. AWS Elastic Container Service (ECS), Google Cloud Run, ...
- containerize applications to simplify infrastructure configuration
- shield applications from each other by using private networks