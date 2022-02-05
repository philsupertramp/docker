# base container
FROM python:3.6-slim

# create dedecated user to run the app with
RUN useradd -m app-user -s /bin/sh

# switch to user
USER app-user

WORKDIR /usr/src/app

COPY requirements.txt .

RUN python -m pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENTRYPOINT ["sh", "entrypoint.sh"]

