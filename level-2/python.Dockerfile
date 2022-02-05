FROM python:3.8

COPY script.py .

CMD ["python", "script.py"]