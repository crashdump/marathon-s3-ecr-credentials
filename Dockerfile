FROM alpine

COPY docker-entrypoint.sh /usr/local/bin/

RUN apk add --update \
    docker \
    python \
    python-dev \
    py-pip \
    build-base \
  && pip install virtualenv \
  && rm -rf /var/cache/apk/*

WORKDIR /opt

ADD requirements.txt /opt/requirements.txt
RUN virtualenv /env && /env/bin/pip install -r /opt/requirements.txt

COPY . /opt

RUN echo '@reboot      /opt/update-credentials.sh' >> /etc/crontabs/root
RUN echo '*/10 * * * * /opt/update-credentials.sh' >> /etc/crontabs/root

CMD ["crond", "-f", "-d", "8"]
