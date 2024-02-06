FROM ubuntu:hirsute-20220113

# create dedecated user to run the app with
RUN useradd -m app-user -s /bin/sh

# switch to user
USER app-user

WORKDIR /usr/src/app
