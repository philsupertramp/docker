FROM python:3.8

# create work directory
WORKDIR /usr/app

# copy requirements file
COPY requirements.txt .

# install requirements
RUN pip install -r requirements.txt

# add script
COPY script.py .

CMD ["python", "script.py"]
