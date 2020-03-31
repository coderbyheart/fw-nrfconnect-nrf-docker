FROM docker

RUN apk add --no-cache git

ARG USER=default
ENV HOME /home/$USER
RUN adduser -D $USER
RUN addgroup docker
RUN addgroup $USER docker
RUN id $USER

USER $USER
WORKDIR $HOME