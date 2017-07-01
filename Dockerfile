FROM java:8-jre-alpine
MAINTAINER kost, https://github.com/kost/docker-alpine

# Set environment variables
ENV ES_NAME=elasticsearch \
	ELASTICSEARCH_VERSION=2.4.1
ENV ELASTICSEARCH_URL=https://download.elastic.co/$ES_NAME/$ES_NAME/$ES_NAME-$ELASTICSEARCH_VERSION.tar.gz

ENV LOGSTASH_NAME=logstash \
	LOGSTASH_VERSION=5.4.1

ENV CONTAINERPILOT_VERSION=2.7.3
ENV CONTAINERPILOT_URL=https://github.com/joyent/containerpilot/releases/download/$CONTAINERPILOT_VERSION/containerpilot-$CONTAINERPILOT_VERSION.tar.gz

ENV LOGSTASH_URL https://artifacts.elastic.co/downloads/$LOGSTASH_NAME/$LOGSTASH_NAME-$LOGSTASH_VERSION.tar.gz

ENV KIBANA_VERSION=4.6.1 \
	KIBANA_NAME=kibana

ENV KIBANA_PKG=$KIBANA_NAME-$KIBANA_VERSION-linux-x86_64
ENV KIBANA_CONFIG=/opt/$KIBANA_NAME-$KIBANA_VERSION-linux-x86_64/config/kibana.yml
ENV KIBANA_URL=https://download.elastic.co/$KIBANA_NAME/$KIBANA_NAME/$KIBANA_PKG.tar.gz

# Download Elasticsearch
RUN apk add --update openssl nodejs bash curl \
    && mkdir -p /opt \  
    && echo "[i] Building elasticsearch" \
    && echo -O /tmp/$ES_NAME-$ELASTICSEARCH_VERSION.tar.gz $ELASTICSEARCH_URL \
    && wget -O /tmp/$ES_NAME-$ELASTICSEARCH_VERSION.tar.gz $ELASTICSEARCH_URL \
    && tar -xzf /tmp/$ES_NAME-$ELASTICSEARCH_VERSION.tar.gz -C /opt/ \
    && ln -s /opt/$ES_NAME-$ELASTICSEARCH_VERSION /opt/$ES_NAME \
    && adduser -D -S elastic \
    && mkdir -p /var/lib/elasticsearch /opt/$ES_NAME/plugins /opt/$ES_NAME/config/scripts \
    && chown -R elastic /var/lib/elasticsearch /opt/$ES_NAME/plugins /opt/$ES_NAME/config/scripts \
    && echo "[i] Building logstash" \
    && wget -O /tmp/$LOGSTASH_NAME-$LOGSTASH_VERSION.tar.gz $LOGSTASH_URL \
    && tar xzf /tmp/$LOGSTASH_NAME-$LOGSTASH_VERSION.tar.gz -C /opt/ \
    && ln -s /opt/$LOGSTASH_NAME-$LOGSTASH_VERSION /opt/$LOGSTASH_NAME \
    && ln -s /opt/$LOGSTASH_NAME/bin/$LOGSTASH_NAME /usr/local/bin/$LOGSTASH_NAME \
    && mkdir /etc/$LOGSTASH_NAME \
    && echo "[i] Building kibana" \
    && wget -O /tmp/$KIBANA_PKG.tar.gz $KIBANA_URL \
    && tar -xzf /tmp/$KIBANA_PKG.tar.gz -C /opt/ \
    && ln -s /opt/$KIBANA_PKG /opt/$KIBANA_NAME \
    && rm -rf /opt/$KIBANA_PKG/node/ \
    && mkdir -p /opt/$KIBANA_PKG/node/bin/ \
    && ln -s $(which node) /opt/$KIBANA_NAME/node/bin/node \
    && /opt/$KIBANA_NAME/bin/kibana plugin -i sence -u https://download.elasticsearch.org/elastic/sense/sense-latest.tar.gz \
    && echo "[i] Container pilot" \
    && echo "[i] Download from $CONTAINERPILOT_URL" \
    && wget -O containerpilot-$CONTAINERPILOT_VERSION.tar.gz $CONTAINERPILOT_URL \
    && tar -xzf containerpilot-$CONTAINERPILOT_VERSION.tar.gz -C /usr/bin \
    && rm containerpilot-$CONTAINERPILOT_VERSION.tar.gz \
    && echo '[i] Finishing' \
    && rm -rf /tmp/*.tar.gz /var/cache/apk/* \
    && echo "[i] Done"

# Add files
COPY config/elasticsearch.yml /opt/elasticsearch/config/elasticsearch.yml
COPY config/jvm.options /opt/$LOGSTASH_NAME-$LOGSTASH_VERSION/config/jvm.options
ADD config/logstash.json /etc/$LOGSTASH_NAME/$LOGSTASH_NAME.json
ADD scripts /scripts

# Specify Volume
VOLUME ["/var/lib/elasticsearch"]

# Exposes
EXPOSE 9200 9300 5601 5014

# CMD
ENTRYPOINT ["/scripts/start.sh"]
