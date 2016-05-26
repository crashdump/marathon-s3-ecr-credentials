# This image is based on quantumobject/docker-alpine and docker:1.10.3-dind images.

# See https://github.com/QuantumObject/docker-alpine
FROM quantumobject/docker-alpine

# Begin docker:1.10.3-dind
RUN apk add --no-cache curl

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.10.3
ENV DOCKER_SHA256 d0df512afa109006a450f41873634951e19ddabf8c7bd419caeb5a526032d86d

RUN curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" -o /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

COPY docker-entrypoint.sh /usr/local/bin/
# End docker:1.10.3-dind

RUN apk add --update \
    bash \
    python \
    python-dev \
    py-pip \
    build-base \
  && pip install virtualenv \
  && rm -rf /var/cache/apk/*

WORKDIR /app

ADD requirements.txt /app/requirements.txt
RUN virtualenv /env && /env/bin/pip install -r /app/requirements.txt

COPY . /app

# We need to at least write one variable to /etc/container_environment/ otherwise /sbin/my_init fails to start.
RUN echo -n true > /etc/container_environment/AWS_DOCKER_LOGIN \
  && echo '*/60	*	*	*	*	. /etc/container_environment.sh; /app/update-credentials.sh' >> /etc/crontabs/root

# Use quantumobject/docker-alpine's init system.
CMD ["/sbin/my_init"]