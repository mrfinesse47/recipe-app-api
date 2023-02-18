# to build go: docker build .

FROM python:3.9-alpine3.13
# we get this from https://hub.docker.com/_/python
LABEL maintainer = "Kevin Mason"

ENV PYTHONBUFFERED 1 
# recommended when running python that way there is no delay
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000
# copies files into the docker image

ARG DEV=false
# this get overriden via docker compose to true when its set to true
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# -m venv creates a virtual env, reduces risk not that much overhead, safeguards against image dep
# /py/bin/pip install --upgrade pip upgrades pip
# we install our packages /py/bin/pip install -r /tmp/requirements.txt
# remove unecessary files rm -rf /tmp , keeps it lightwieght
# adduser, best practice to not use root user, best for security, if attacker gets root thats horrible
# django-user is the user name
# we run these as all one command so it doesnt create a new image layer each command


ENV PATH="/py/bin:$PATH"

# updates the path environment variable, that way we dont need to specify full path to virtual env

USER django-user

# finally switch to the user