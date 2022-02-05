FROM python:3.9

RUN mkdir -p /usr/app

WORKDIR /usr/app

COPY script.py /usr/app/script.py


CMD ["python3", "script.py"]

