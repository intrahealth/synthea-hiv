#/usr/bin/env bash

# sanity checks
for filename in output/fhir/*.json
do
    echo $filename
    cat $filename | grep "HIV"
done


