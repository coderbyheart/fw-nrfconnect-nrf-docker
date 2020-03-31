FROM docker

RUN apk add --no-cache git

ARG USER=default
ENV HOME /home/$USER
RUN adduser --uid 1001 -D $USER && \
    addgroup docker && \
    addgroup $USER docker && \
    id $USER

USER $USER
WORKDIR $HOME