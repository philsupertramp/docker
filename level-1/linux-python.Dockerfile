# Base image
FROM ubuntu:latest

# install interpreter
RUN apt update -y
RUN apt install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt update -y
RUN apt install -y python3.8

ENV PYTHONPATH="/usr/app"

RUN mkdir -p /usr/app

WORKDIR /usr/app

COPY script.py /usr/app/script.py

CMD ["python3", "script.py"]

