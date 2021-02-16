#!/usr/bin/env bash
set -ex

# automate tagging with the short commit hash
docker build --no-cache -t intrahealth/synthea-hiv:$(git rev-parse --short HEAD) .
docker tag intrahealth/synthea-hiv:$(git rev-parse --short HEAD) intrahealth/synthea-hiv
docker tag intrahealth/synthea-hiv:$(git rev-parse --short HEAD) intrahealth/synthea-hiv:pop100
docker push intrahealth/synthea-hiv:$(git rev-parse --short HEAD)
docker push intrahealth/synthea-hiv:pop100
docker push intrahealth/synthea-hiv:latest

# create 1000 patients
docker build --no-cache --build-arg POP=1000 -t intrahealth/synthea-hiv:pop1000 .
docker tag intrahealth/synthea-hiv:pop1000 intrahealth/synthea-hiv:pop1000
docker push intrahealth/synthea-hiv:pop1000