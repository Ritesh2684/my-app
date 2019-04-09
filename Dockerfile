FROM ubuntu:18.04

LABEL maintainer="ritesh"

VOLUME /tmp
ADD target/my-app* my-app.jar
RUN sh -c 'touch /my-app.jar'
ENTRYPOINT ["tail","-f", "/dev/null"]