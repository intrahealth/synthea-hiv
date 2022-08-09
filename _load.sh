#/usr/bin/env bash

# export FHIR="https://blaze.life.uni-leipzig.de/fhir"
export FHIR="https://cloud.alphora.com/sandbox/r4/cqm/fhir"
# export FHIR="http://localhost:8080/cqf-ruler-r4/fhir"

# load our revised file
cat ./preparedsynthea.json | curl -X POST -H "Content-Type: application/fhir+json;charset=utf-8" --data @- ${FHIR}
# for testing also load on public hapi fhir since alphora can't be search-queried identifier
cat ./preparedsynthea.json | curl -X POST -H "Content-Type: application/fhir+json;charset=utf-8" --data @- 'http://hapi.fhir.org/baseR4'

rm output/fhir/hospital*
cat output/fhir/practitioner*.json | curl -X POST -H "Content-Type: application/fhir+json;charset=utf-8" --data @- ${FHIR}

# todo: loads org stuff twice, but doesn't hurt anything
for FILE in output/fhir/*.json
do 
    curl -s -X POST -H "Content-Type: application/fhir+json;charset=utf-8" -d @$FILE ${FHIR}
done