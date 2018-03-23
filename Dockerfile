FROM confluentinc/cp-kafka-connect-base:latest

MAINTAINER rzrbld

ENV DEBEZIUM_VERSION=0.7.5 \
    KAFKA_CONNECT_PLUGINS_DIR=/kafka/connect \
    MAVEN_CENTRAL="https://repo1.maven.org/maven2" \
    MD5SUMS="MONGODB_MD5=eca32461520fe26246c54fc675ef7521 MYSQL_MD5=5b31f16787ae5691e4bb67721e10f8dc POSTGRES_MD5=730cc8acdb4f272498869b986e35ee0a"

#
# Download connectors, verify the contents, and then install into the `$KAFKA_CONNECT_PLUGINS_DIR/debezium` directory...
#
RUN eval $MD5SUMS &&\
    mkdir $KAFKA_CONNECT_PLUGINS_DIR &&\
    for CONNECTOR in {mysql,mongodb,postgres}; do \
    curl -fSL -o /tmp/plugin.tar.gz \
                 $MAVEN_CENTRAL/io/debezium/debezium-connector-$CONNECTOR/$DEBEZIUM_VERSION/debezium-connector-$CONNECTOR-$DEBEZIUM_VERSION-plugin.tar.gz &&\
    declare MD5_PARAM_NAME="${CONNECTOR^^}_MD5" &&\
    echo "${!MD5_PARAM_NAME}  /tmp/plugin.tar.gz" | md5sum -c - &&\
    tar -xzf /tmp/plugin.tar.gz -C $KAFKA_CONNECT_PLUGINS_DIR &&\
    rm -f /tmp/plugin.tar.gz; \             
    done; \
    curl -fSL -o /tmp/sqlite-connect.zip \
                 https://github.com/rzrbld/kafka-connector-jdbc/archive/master.zip &&\
    unzip /tmp/sqlite-connect.zip -d $KAFKA_CONNECT_PLUGINS_DIR &&\
    rm -f /tmp/sqlite-connect.zip; \
