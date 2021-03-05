#/usr/bin/env bash

cd "$HOME/src/github.com/citizenrich/hiv-indicators/output"
for f in FHIRCommon HIVINDAV1 AgeRanges HIVIndicators
do
    curl -X POST -H "Content-Type: application/fhir+json;charset=utf-8" --data @Library-${f}.json http://localhost:8080/fhir/Library
done

for f in HIVINDAV1 hiv-indicators
do
    curl -X POST -H "Content-Type: application/fhir+json;charset=utf-8" --data @Measure-${f}.json http://localhost:8080/fhir/Measure
done


