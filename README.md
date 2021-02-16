# Synthea-HIV

> This is an experimental module for HIV for global health use cases. It is very naive and is not ready for merging into Synthea.

The /modules folder has a simple and experimental module for generating persons with HIV for the [synthea](https://github.com/synthetichealth/synthea) fake data generator. It is very naive and is not ready for merging into Synthea.

The following is the status of what codesystems/valuesets are generated:

## Status

### Added

HIV Test Results (from mADX and other sources)
* code "HIV Negative": code '165815009' from "SNOMED-CT"
* code "HIV Positive": code '165816005' from "SNOMED-CT"
* code "HIV 1 and 2 tests - Meaningful Use set": '75622-1' from "LOINC"

ConditionOnset: HIV infection (may be useful)
* SNOMED-CT 86406008

History of ART Therapy (Needs valueset and distribution of adherence)
* code "History of antiretroviral therapy (situation)": '432101000124108' from "SNOMED-CT"
(http://purl.bioontology.org/ontology/SNOMEDCT/432101000124108)

Viral load
* LOINC codes of 25836-8 (copies/mL)
* Suppressed viral load (<1000 copies/mL)
* Used range of 200 (very low) -> 1000000 (very high)


### Not added

Pregnancy, breastfeeding
* The pregnancy module could be adopted but named valuesets are apparently out of use:
https://phinvads.cdc.gov/vads/ViewCodeSystemConcept.action?oid=2.16.840.1.113883.6.96&code=146789000
* Apparently out of use:
    code "Pregnant": '146789000' from "SNOMED-CT"
    code "Breastfeeding": '169750002' from "SNOMED-CT"

## How to use - Docker

> The docker images use a multipart build process so the final compressed images are under 20MB.

* A buildtime var `POP` as population.
* A runtime var `FHIR` which is the FHIR server.

Run the hosted build. On run it loads patients into the `host.docker.internal:8080/fhir` endpoint. This can be changed using an environment variable, `FHIR`.
```bash
docker run intrahealth/synthea-hiv:latest
# same as intrahealth/synthea-hiv:pop100
```

There is also an image with 1000 patients, use:
```
docker run intrahealth/synthea-hiv:pop1000
```

Or, build with the number of patients preferred and use your own tag. 100 is the default.
```bash
docker build -t stuff --build-arg POP=200 .
docker run stuff
```

## Sanity checks on FHIR Resources

> Install the awesome [jq](https://stedolan.github.io/jq/download/) for fast and intuitive parsing.

Summary stats:

```bash
curl -s http://localhost:8080/fhir/Patient?_summary=count | jq '{Patient: .total}'
curl -s http://localhost:8080/fhir/Condition?_summary=count | jq '{Condition: .total}'
curl -s http://localhost:8080/fhir/Encounter?_summary=count | jq '{Encounter: .total}'
curl -s http://localhost:8080/fhir/DiagnosticReport?_summary=count | jq '{DiagnosticReport: .total}'
curl -s http://localhost:8080/fhir/Observation?_summary=count | jq '{Observation: .total}'
```

Patient
```bash
# Key info from Patient
# curl -s http://localhost:8080/fhir/Patient | jq '.entry[].resource.id, .entry[].resource | {gender: .gender, birthDate: .birthDate, deceasedDateTime: .deceasedDateTime}'
curl -s http://localhost:8080/fhir/Patient?_count=10000 | jq '.entry[] | {id: .resource.id, gender: .resource.gender, birthDate: .resource.birthDate, deceasedDateTime: .resource.deceasedDateTime}'
```

Condition with HIV
```bash
# curl http://localhost:8080/fhir/Condition?_count=10000&_content=HIV
# see all conditions
curl -s http://localhost:8080/fhir/Condition?_count=10000 | jq '.entry[] | .resource.code[], .resource.subject.reference, .resource.encounter.reference'
```

DiagnosticReport for HIV tests and death certs
```bash
curl -s http://localhost:8080/fhir/DiagnosticReport?_count=10000 | jq '.entry[] | .resource.code, .resource.subject.reference, .resource.encounter.reference, .resource.result[]'
```

Observation
```bash
curl -s http://localhost:8080/fhir/Observation?_count=10000&_content=HIV | jq '.entry[] | .resource.code.coding[], .resource.subject.reference, .resource.encounter.reference, .resource.valueCodeableConcept[]'
```

## Create patients directly from JAR for supporting IG test cases

* Clone this repo
* Change dir into it.
* Download the latest release of Synthea, which at this moment is:
```
wget https://github.com/synthetichealth/synthea/releases/download/v2.7.0/synthea-with-dependencies.jar
```

Generate patients in the current directory.
* `--exporter.use_uuid_filenames true` uses only the UUID as filenames.
* `--exporter.years_of_history 0` generates all patient history.
* `-d modules/` adds the local module path `modules`.
* `-m hiv*` says to only create patients in `hiv*` module.
* `-s 123` uses a seed to create the same dataset every time.

Like so:
```bash
java -jar synthea-with-dependencies.jar -p 100 -d modules/ -m hiv* -s 123 --exporter.years_of_history 0 --exporter.years_of_history 0 --exporter.use_uuid_filenames true
```

The patient records in FHIR are in `/output`
```
cd /output
```

Now a one-liner to put bundles into HAPI:
```bash
for FILE in *; do curl -X POST -H "Content-Type: application/fhir+json;charset=utf-8" -d @$FILE http://localhost:8080/fhir ; done
```
Or... to rename the files for use in testing IGs, each patient bundle must have its own folder.
```bash
for x in ./*.json; do mkdir "${x%.*}" && mv "$x" "${x%.*}" && mv ; done
```

Then remove for now the practitioner and hospital bundles as they can't be processed in IG publisher
```
rm -r output/fhir/hospital*
rm -r output/fhir/practitioner*
```

## Options for running


* Copy the folders into the IG for testing. Use the [cqframework/hiv-indicators]9https://github.com/cqframework/hiv-indicators) repository and the CQL Atom plugin.
* Run with HAPI with CQL processing:
See: [CQL Development and Unit Testing with hapi-fhir and hapi-fhir-jpaserver-starter](https://docs.google.com/document/d/1nMChThWev-FRsjvsqDPEdS-0qrjqONoMj4livjD2dqQ)
* Run against the DBCB team's server can be used at: https://cqm-sandbox.alphora.com/cqf-ruler-r4/fhir

## Some CQL hints

* Double quotes are for identifiers and single quotes represent string literals, for example, "female" should be 'female'.
* Check for odd copy/paste errors in quotes.
* Required libraries: `include FHIRHelpers version '4.0.1'` Use of FHIRHelpers is implicit in the translator, based on the modelinfo file with FHIR.
* The CQL/ELM processing code does not update the Library resource. If a Library has CQL content it is converted to ELM "on-the-fly" as it is used. This means the CQL must be included as Base64-encoded.




