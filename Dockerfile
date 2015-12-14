FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive
ENV GOPATH /opt/go

RUN apt-get update && apt-get install -y wget && \
    wget https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.5.linux-amd64.tar.gz
ENV GOROOT=/usr/local/go
ENV PATH=$PATH:$GOROOT/bin


RUN apt-get -y install software-properties-common && \
    add-apt-repository ppa:vbernat/haproxy-1.6 && \
    apt-get update && apt-get install -y haproxy

RUN apt-get install -yqq software-properties-common && \
    add-apt-repository -y ppa:vbernat/haproxy-1.5 && \
    apt-get update -yqq && \
    apt-get install -yqq git mercurial supervisor && \
    rm -rf /var/lib/apt/lists/*

ADD . /opt/go/src/github.com/QubitProducts/bamboo
ADD builder/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD builder/run.sh /run.sh

WORKDIR /opt/go/src/github.com/QubitProducts/bamboo

RUN go get github.com/tools/godep && \
    go get -t github.com/smartystreets/goconvey && \
    go build && \
    ln -s /opt/go/src/github.com/QubitProducts/bamboo /var/bamboo && \
    mkdir -p /run/haproxy && \
    mkdir -p /var/log/supervisor

VOLUME /var/log/supervisor

RUN apt-get clean && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    rm -f /etc/ssh/ssh_host_*

EXPOSE 80 8000

CMD /run.sh

