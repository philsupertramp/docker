FROM python:3.8

WORKDIR /usr/app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY app.py .

ENV FLASK_APP=app

CMD ["flask", "run", "--host=0.0.0.0"]
