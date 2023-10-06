#pull official base image
FROM python:3.11.4-slim-buster


# set env variables

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies
RUN apt-get update -y && apt-get -y install python3-pip python3-cffi python3-brotli libpango-1.0-0 libpangoft2-1.0-0
RUN pip install --upgrade pip

# ENV VIRTUAL_ENV=/opt/virtualenv
# RUN python3 -m virtualenv $shop_env
# ENV PATH="$shop_env/bin:$PATH"

RUN pip install virtualenv
RUN virtualenv shop_env
RUN su -c "source shop_env/bin/activate"

COPY ./requirements.txt .

RUN pip install -r requirements.txt

#copy project

COPY .  .


# create unprivileged user
RUN adduser --disabled-password --gecos '' myuser
# RUN pip install virtualenv
# RUN su -m myuser -c "virtualenv shop"
# RUN su -m myuser -c "source shop/bin/activate"
RUN chmod +rwx run_celery.sh run_celery_beat.sh run_web.sh