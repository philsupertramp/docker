FROM python:3.8

# use and create workdir
WORKDIR /usr/app

# copy dependencies file
COPY requirements.txt .

# install dependencies
RUN pip install -r requirements.txt

# copy app content
COPY app.py .

# set a required environment variable
ENV FLASK_APP=app

CMD ["flask", "run", "--host=0.0.0.0"]
