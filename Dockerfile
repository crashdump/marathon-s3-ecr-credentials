FROM alpine:3.3

RUN apk add --update python python-dev py-pip build-base
RUN pip install virtualenv
RUN apk add docker=1.9.1-r2 \
    && rm -rf /var/cache/apk/*

WORKDIR /opt

ADD requirements.txt /opt/requirements.txt
RUN virtualenv /env && /env/bin/pip install -r /opt/requirements.txt

COPY . /opt

RUN echo '@reboot      /opt/update-credentials.sh' >> /etc/crontabs/root
RUN echo '*/10 * * * * /opt/update-credentials.sh' >> /etc/crontabs/root

CMD /opt/update-credentials.sh && crond -f -d 8
