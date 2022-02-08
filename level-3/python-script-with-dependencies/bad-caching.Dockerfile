FROM python:3.8

# create work directory
WORKDIR /usr/app

# copy files into container
COPY . .

# install requirements
RUN pip install -r requirements.txt

CMD ["python", "script.py"]
