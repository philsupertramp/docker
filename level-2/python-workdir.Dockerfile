FROM python:3.8

WORKDIR /usr/app

COPY script.py .

CMD ["python", "script.py"]
