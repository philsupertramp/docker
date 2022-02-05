# Level 2

## Glossary
- "volume": a storage within the filesystem represented by a directory
- "network": a range of IP addresses to communicate in

## Adding files into an image
Let's assume we want to wrap a python script called `script.py` into our image, without
doing the manual work of committing a running container.  
The file `script.py` looks like that:
```python
#!/usr/bin/env python3
"""
Simple python script to demonstrate usage in container image.
"""


if __name__ == '__main__':
    print('This script is working.')

```
To add this file into an image during build time we can use the `COPY` statement
```dockerfile
FROM python:3.8

COPY script.py .

CMD ["python", "script.py"]
```

### Building the image
```shell
docker build -f python.Dockerfile -t python-level2:latest .
```
#### Running a container using the image
```shell
> docker run python-level2:latest
This script is working.
```

> But what's the target, and where does the `script.py` end up?

```shell
> docker run -it python2:latest bash
root@9dd4b046bd58:/# echo $PWD
/
```
As you can see the file ended up in the root (`/`) directory of the running container, which isn't great and we should change that.

## Setting a working directory
To set a proper working directory we use the statement `WORKDIR`
```dockerfile
FROM python:3.8

WORKDIR /usr/app

COPY script.py .

CMD ["python", "script.py"]
```

#### Building the image
```shell
docker build -f python-workdir.Dockerfile -t python-workdir-level2:latest .
```
#### Running a container using the image
```shell
> docker run python-workdir-level2:latest
This script is working.
```

And where's the script now?
```shell
docker run -it python-workdir-level2:latest bash
root@29bebb0536ad:/usr/app# echo $PWD
/usr/app
```

Not just files, also directories can be added into an image
```dockerfile
FROM python:3.8

WORKDIR /usr/app

COPY . .

CMD ["python", "script.py"]
```
Will copy the current directory into the image.  
#### Ignoring files
In some cases we don't want to list files explicitly in an image file and worry elsewhere
about file exclusion from the build process. For this we can add a `.dockerignore` file
into directories, which works like `.gitignore` files.

As an example we can exclude all dockerfiles with:
```text
*Dockerfile
```

## Mounting the filesystem into a container
Sometimes we'd like to use a running container to develop a script or an app
and it's rather inconvenient to always rebuild the image after we change a line in the script.
So instead of rebuilding the image, we have the option of mounting a volume
into a running container.
```shell
> docker run -it -v $PWD:/usr/app python-workdir-level2:latest
This script is working.

# edit the file
> echo -e "$(cat script.py | sed 's/is working/is still working/g')" > script.py

# run the script again 
> docker run -it -v $PWD:/usr/app python-workdir-level2:latest
This script is still working.
```

## Exposing a port from a container
Imagine we want to host a simple HTML site in our local network.  
The static page looks is a simple "Hello World!" `static-html-directory/index.html`
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello World</title>
</head>
<body>
<h1>Hello World!</h1>
</body>
</html>
```
For this we can use the [`nginx`](https://hub.docker.com/_/nginx) image as a base
```dockerfile
FROM nginx

COPY static-page.html /usr/share/nginx/html/
```

```shell
> docker build -f nginx.Dockerfile -t webpage:latest .
...
> docker run webpage:latest
...
```
##### Problem
It looks like the server is running, and we see output in the logs, usually a webserver hosts on port 80, so let's try 
```shell
> curl -X 'GET' "http://localhost:80"
curl: (7) Failed to connect to localhost port 80 after 0 ms: Connection refused
> curl -X 'GET' "http://127.0.0.1:80"
curl: (7) Failed to connect to 127.0.0.1 port 80 after 0 ms: Connection refused
```
Neither `localhost` nor `127.0.0.1` answer anything on that port.

##### Solution
We need to manually tell the `docker run` command to do port forwarding. We can do that the following
```shell
> docker run -p 8080:80 webpage:latest
```
the `-p` flag awaits an argument with the syntax `host:container` with
  - `host`: IP address and/or port number on the host machine
  - `container`: IP address and/or port number within the container

And now the HTML page is available at [http://localhost:8080/index.html](http://localhost:8080/index.html) or [http://127.0.0.1:8080/index.html](http://127.0.0.1:8080/index.html).
And due to the fact that we called it `index.html`, it's also available without the postfix `index.html`
```shell
> curl -X 'GET' 'http://127.0.0.1:8080'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello World</title>
</head>
<body>
<h1>Hello World!</h1>
</body>
</html>
```
**Note:** of course you can use `-p 80:80` to forward the port of the container to the host machine. This also makes your webpage available at [http://localhost](http://localhost). But
I would strongly advise against doing so, unless you really know what you're doing.

## Running a container in "detached" mode
Now that we have a static website in place we also want to run it as a background process on our server.
We can do that using the `-d` flag
```shell
> docker run -p 8080:80 -d webpage:latest
ac3c90ed3b131ce6c5b3dd451652768d9597482030ae09d759d4b0522c69000d
```
This gives us a UID for the created container.
Using
```shell
> docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS                                   NAMES
ac3c90ed3b13   webpage:latest   "/docker-entrypoint.…"   23 seconds ago   Up 22 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   brave_bouman
```
we can list currently running containers. As you can see 13 characters are enough to identify our container. Additionally
we can later use the `NAMES` column to access our container, e.g.
```shell
> docker logs brave_bouman
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2022/02/05 14:08:34 [notice] 1#1: using the "epoll" event method
2022/02/05 14:08:34 [notice] 1#1: nginx/1.21.6
2022/02/05 14:08:34 [notice] 1#1: built by gcc 10.2.1 20210110 (Debian 10.2.1-6) 
2022/02/05 14:08:34 [notice] 1#1: OS: Linux 5.10.93-1-MANJARO
2022/02/05 14:08:34 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2022/02/05 14:08:34 [notice] 1#1: start worker processes
2022/02/05 14:08:34 [notice] 1#1: start worker process 32
2022/02/05 14:08:34 [notice] 1#1: start worker process 33
2022/02/05 14:08:34 [notice] 1#1: start worker process 34
2022/02/05 14:08:34 [notice] 1#1: start worker process 35
```
Or stopping the container
```shell
>  docker stop brave_bouman
brave_bouman
> docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
And start it again
```shell
> docker start brave_bouman
brave_bouman
> docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED         STATUS         PORTS                                   NAMES
ac3c90ed3b13   webpage:latest   "/docker-entrypoint.…"   6 minutes ago   Up 4 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   brave_bouman
```

## Remove a container once it's stopped
For single use containers we can use the `--rm` flag in the `docker run` command
```shell
> docker run -p 8080:80 -d --rm webpage:latest
> docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED         STATUS         PORTS                                   NAMES
3a0283333749   webpage:latest   "/docker-entrypoint.…"   5 seconds ago   Up 3 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   crazy_mestorf
> docker stop crazy_mestorf
crazy_mestorf
> docker start crazy_mestorf
Error response from daemon: No such container: crazy_mestorf
Error: failed to start containers: crazy_mestorf
```

## Summary:
- `docker run`
  - `-v` to mount directories into a countainer
  - `-p` for port forwarding
  - `-d` to run in detached mode
  - `-it` for interactive mode
  - `--rm` remove after stopping (this invalidates the identifiers for this container and removes it completely once it's stopped)
- `docker ps`: List all running containers
- `docker stop`: to stop a running container
- `docker stop`: to start a stopped container
