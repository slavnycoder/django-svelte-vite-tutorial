FROM node:18 as frontend
COPY frontend/ /usr/src/frontend/
WORKDIR /usr/src/frontend/

RUN npm i
RUN npm run build

FROM python:3.8-slim-bullseye

# apt
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y libmagic-dev
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /var/cache/apt

ADD requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt --disable-pip-version-check --no-cache-dir

COPY . /usr/src/django_be/
COPY --from=frontend /usr/src/frontend/dist /frontend/html
WORKDIR /usr/src/django_be/
