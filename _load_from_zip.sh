#/usr/bin/env bash

# export FHIR="https://blaze.life.uni-leipzig.de/fhir"
export FHIR="https://cloud.alphora.com/sandbox/r4/cqm/fhir"
# export FHIR="http://localhost:8080/cqf-ruler-r4/fhir"

# assumes the fhir folder is unzipped under fhir/

# load our revised file
echo "Loading revised orgs file"
cat fhir/preparedsynthea.json | curl -X POST -H "Content-Type: application/fhir+json;charset=utf-8" --data @- ${FHIR}

cat fhir/practitioner*.json | curl -X POST -H "Content-Type: application/fhir+json;charset=utf-8" --data @- ${FHIR}

# todo: loads org stuff twice, but doesn't hurt anything
for FILE in fhir/*.json
do 
    curl -s -X POST -H "Content-Type: application/fhir+json;charset=utf-8" -d @$FILE ${FHIR}
done