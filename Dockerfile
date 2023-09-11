#pull official base image
FROM python:3.11.4-slim-buster


# set env variables

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies
RUN apt-get update -y && apt-get -y install python3-pip python3-cffi python3-brotli libpango-1.0-0 libpangoft2-1.0-0
RUN pip install --upgrade pip

COPY ./requirements.txt .

RUN pip install -r requirements.txt

#copy project

COPY .  .


# create unprivileged user
RUN adduser --disabled-password --gecos '' myuser
RUN su -m myuser -c "source shop/bin/activate"
RUN chmod +rwx run_celery.sh run_celery_beat.sh run_web.sh