FROM python:3.10-slim

WORKDIR /app

RUN pip install --upgrade pip setuptools jaraco.context

COPY app.py .

CMD ["python", "app.py"]
