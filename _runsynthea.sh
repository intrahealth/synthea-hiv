#/usr/bin/env bash

# plan:
# export separate bundles for practitioner and location and load those first
# modify the location/org resources for ou
# load org/location resources onto fhir server
# then the cql gets the ou identifier?


rm -rf output/fhir/*

cd $HOME/src/github.com/synthetichealth/synthea
rm -rf output/fhir/*
git checkout -- src/main/resources/modules/lookup_tables/hiv_diagnosis_early.csv
git checkout -- src/main/resources/modules/lookup_tables/hiv_diagnosis_later.csv
git checkout -- src/main/resources/modules/lookup_tables/hiv_mortality_very_early.csv
git checkout -- src/main/resources/modules/lookup_tables/hiv_mortality_early.csv
git checkout -- src/main/resources/modules/lookup_tables/hiv_mortality_later.csv
python3 $HOME/src/github.com/intrahealth/synthea-hiv/increaseprev.py

# run it: this works
# puts stuff in this repo: $HOME/src/github.com/intrahealth/synthea-hiv/output

# fix the random number seed for patients
# fix the random number seed for clinicians
# current system time you are running the simulation
# export years of patient history, limit this to avoid huge bundles
# turn off us core profile
# stops from looping forever to keep patient alive
# gen transaction bundles for patients
# separate practitioner and location/organization bundles
./run_synthea -p 100 -s 123 -cs 123 -r 20221231 \
--exporter.use_uuid_filenames true \
--exporter.years_of_history 2 \
--exporter.baseDirectory $HOME/src/github.com/intrahealth/synthea-hiv/output \
--exporter.fhir.use_us_core_ig false \
--generate.max_attempts_to_keep_patient 10 \
--exporter.fhir.transaction_bundle true \
--exporter.practitioner.fhir.export true \
--exporter.hospital.fhir.export true \
--generate.only_alive_patients true



# --generate.demographics.default_file geography/demographics_uk.csv \
# --generate.geography.zipcodes.default_file geography/zipcodes_uk.csv \
# --generate.geography.timezones.default_file geography/timezones_uk.csv \
# --generate.geography.country_code Elements \
# --generate.payers.insurance_companies.default_file payers/insurance_companies_uk.csv \
# --generate.payers.insurance_companies.medicare "National Health Service" \
# --generate.payers.insurance_companies.medicaid "National Health Service" \
# --generate.payers.insurance_companies.dual_eligible "National Health Service" \