FROM openjdk:16-jdk-alpine
RUN apk --no-cache add openssl wget git curl
RUN wget https://github.com/synthetichealth/synthea/releases/download/master-branch-latest/synthea-with-dependencies.jar
RUN git clone https://github.com/intrahealth/synthea-hiv.git

ARG POP=100

RUN java -jar synthea-with-dependencies.jar \
    -p ${POP} \
    # --exporter.fhir.bulk_data true \
    # keep all patient history
    --exporter.years_of_history 0 \
    -d synthea-hiv/modules \
    -m hiv* \
    # seed to create the same patients every time
    -s 123 \
    --exporter.fhir.use_us_core_ig false

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
CMD cat hospital*.json | curl -X POST -H "Content-Type: application/fhir+json" --data-binary @- ${FHIR} \
&& cat practitioner*.json | curl -X POST -H "Content-Type: application/fhir+json" --data-binary @- ${FHIR} \
&& for FILE in * ; do curl -s -X POST -H "Content-Type: application/fhir+json" -d @$FILE ${FHIR} ; done



