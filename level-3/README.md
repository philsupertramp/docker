# Level 3:

## Resolving security concerns
We've seen several times already how to use a directory other than
`/` for storing the files of our app within a container.  
But apart from having an unorganized container and potentially allowing other users of your running
container to access your files, this does not too much harm for the running container or the host machine. 
A bigger issue is the fact that we execute everything as the `root` user.
### Dedicated user to solve security issues
In order to not run the container as `root`, as we found out in [`level-1`](/level-1), we
need to create a dedicated user to run the task.

To do so we can use the `USER` statement, as seen in `linux.Dockerfile`

```dockerfile
FROM ubuntu:21.04

# create dedecated user to run the app with
RUN useradd -m app-user -s /bin/sh

# switch to user
USER app-user

WORKDIR /usr/src/app
```
Every image starts off using `root`, we first need to create a user, and provide a default shell for that user.
Then we can switch over and continue as the dedicated user.  
Now we can use the container just like before

```shell
> docker build -f linux.Dockerfile -t ubuntu-user:latest .
> docker run ubuntu-user:latest whoami
app-user
```

## Python Script with dependencies
A Python script with dependencies
(see [python-script-with-dependencies](python-script-with-dependencies))

```shell
> cd python-script-with-dependencies
# build the image
> docker build -t python-script-lvl-3:latest .
# start a container using the image
> docker run -v $PWD:/usr/app python-script-lvl-3:latest
```
This generated a beautiful image for us `python-script-with-dependencies/mandelbrot.png`  
![mandelbrot.png](mandelbrot.png)
## A simple Python webapp
[flask-app](flask-app) can be build using
```shell
> docker build -f flask-app/Dockerfile -t flask-app:latest flask-app 
```
and run using
```shell
> docker run -v $PWD/flask-app:/usr/app -p 8000:5000 flask-app:latest
```
The app is now available at [http://127.0.0.1:8000](http://127.0.0.1:8000)  
![flask-app.png](flask-app.png)

To simplify the execution and configure the ports/volumes in code
we can use the tool `docker-compose`.
### [docker-compose](https://docs.docker.com/compose/)
Using `docker-compose` we can configure containers in code using `YAML`
to wrap the `flask-app` container config we create a `docker-compose.yml` file
```yaml
version: '3' # < required

services: # begins definition of services to run in composition
  flask-app: # start of definition of the "flask-app" service
    image: flask-app:latest # the image to use for the service
    build: # build config if the image is not available
      context: .
    ports: # ports to forward from the running container
      - "8000:5000"
    volumes: # volumes to mount into the container
      - ".:/usr/app"
    command: [ # the command to run in the container
       "flask", "run", "--host=0.0.0.0"
    ]
```
using this [`flask-app/docker-compose.yml`](flask-app/docker-compose.yml) file we can start the service using
```shell
> docker-compose -f flask-app/docker-compose.yml up
```
or from within the `flask-app` directory shortly
```shell
> docker-compose up
```
we can launch the app in detached mode using `-d`.  
To clean up and remove volumes and containers run
```shell
> docker-compose -f flask-app/docker-compose.yml down -v
```

## Django & PostgreSQL
Sometimes we want to launch multiple containers and want them to communicate in between.
Suppose we have a webapp that requires a running PostgreSQL instance.
See [django-postgres-docker-compose](django-postgres-docker-compose)
```shell
> cd django-postgres-docker-compose
# build & run the setup
> docker-compose up
```

## Resource Allocation
### Common Resource Types
To specify which resources a container is allowed to use on the host machine we can provide
specific resource parameters in `docker run`
- `-m=` to set the amount of memory for the running container
- `--cpus` specifies how much of the available CPU resource the container can use

Example:
```shell
> docker run -v $PWD:/usr/app -m="6M" --cpus="0.1" python:3.8 python /usr/app/script.py
```
for more see [the docs](https://docs.docker.com/config/containers/resource_constraints/).

### GPU support
Docker comes with full support for NVIDIA GPUs – according to their [bug tracker](https://github.com/docker/cli/issues/2063).  
For more info consult the [official docs](https://docs.docker.com/config/containers/resource_constraints/#gpu).


_A comment from Linus Torvalds about the cooperation between Linux and NVIDIA:_  
https://www.youtube.com/watch?v=IVpOyKCNZYw

## More resources
- A list of resources for `docker-compose`: https://github.com/docker/awesome-compose

