# syntax=docker/dockerfile:1

FROM python:3.9.2

WORKDIR online-bank

COPY requirements.txt requirements.txt

RUN python3 -m pip install --upgrade pip

RUN pip install -r requirements.txt

COPY . .

CMD ["python3", "-m", "flask", "run", "--host=0.0.0.0"]
