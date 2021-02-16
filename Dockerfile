FROM openjdk:8-jre-alpine3.9
RUN apk --no-cache add openssl wget git curl
RUN wget https://github.com/synthetichealth/synthea/releases/download/v2.7.0/synthea-with-dependencies.jar
RUN git clone https://github.com/intrahealth/madx-hiv.git

ARG POP=100

RUN java -jar synthea-with-dependencies.jar \
    -p ${POP} \
    # --exporter.fhir.bulk_data true \
    # keep all patient history
    --exporter.years_of_history 0 \
    -d madx-hiv/synthea/modules \
    -m hiv* \
    # seed to create the same patients every time
    -s 123

# ENV DOCKERIZE_VERSION v0.5.0
# RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
#     && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
#     && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

FROM curlimages/curl:7.74.0
# COPY --from=0 /usr/local/bin/dockerize /usr/local/bin/
USER curl_user
WORKDIR /home/curl_user
COPY --from=0 output/fhir/* .

ARG FHIR=http://host.docker.internal:8080/fhir
ENV FHIR=$FHIR

# CMD dockerize -wait ${FHIR}/metadata for FILE in * ; do curl -X POST -H "Content-Type: application/fhir+json" -d @$FILE ${FHIR} ; done
# errors with dockerize, comment out for now
CMD for FILE in * ; do curl -s -X POST -H "Content-Type: application/fhir+json" -d @$FILE ${FHIR} ; done



