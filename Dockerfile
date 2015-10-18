FROM java:8-jre
MAINTAINER Jieke Choo <jiekechoo@sectong.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install --no-install-recommends -y supervisor

RUN echo "Asia/Shanghai" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# Elasticsearch
RUN \
    apt-key adv --keyserver pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4 && \
    if ! grep "elasticsearch" /etc/apt/sources.list; then echo "deb http://packages.elastic.co/elasticsearch/1.7/debian stable main" >> /etc/apt/sources.list;fi && \
    apt-get update

RUN \
    apt-get install --no-install-recommends -y elasticsearch && \
    apt-get clean && \
    sed -i '/#cluster.name:.*/a cluster.name: logstash' /etc/elasticsearch/elasticsearch.yml && \
    sed -i '/#path.data: \/path\/to\/data/a path.data: /data' /etc/elasticsearch/elasticsearch.yml

ADD etc/supervisor/conf.d/elasticsearch.conf /etc/supervisor/conf.d/elasticsearch.conf

CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]
