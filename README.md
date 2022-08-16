# Synthea-HIV

This is a worked example of generating [Synthea](https://github.com/synthetichealth/synthea) longitudinal medical records for a fake population. The difference between this and ordinary Synthea is that HIV positivity has a higher prevalence and longer mortality to facilitate testing clinical quality measures, in addition to having random DHIS2 org units attached as identifiers. If you don't know what DHISs is and don't work in HIV-related public health programs, this repo probably isn't for you. But, the shell scripts may be interesting. :)

## How to Use

* Downlaod the already prepared records under releases and unzip. Warning: the files unzip to around 1.2GB.
* POST the files to your favorite FHIR server. There's an example script `_load_from_zip.sh`. The `preparedsynthea.json` file contains the modified organization resources and is loaded first. Then the practitioner file, then the patients.

## Development

* For performance with millions of records, this tooling trys to use simdjson but it is not strictly necessary.
* The paths are hard-coded. It assumes source repos are in `$HOME/src/github.com/<org/user>/whatever`
* There used to be a Docker container for this, but there needs to be manual intervention to add DHIS2 org units to the FHIR identifiers for Organization resources in the Synthea output before it is uploaded. This can't be done in Synthea as it assigns unique UUIDs dynamically.

* Clone synthea. Files need to be modified in there but they are put back to previous state afterward.
* Clone this repo. Run `_runsynthea.sh`. 
    * This invokes the `increaseprev.py` script, which invokes the `increaseprev.py` tool. (todo: This could be made cleaner.)
    * Runs synthea
    * and puts records in this repo.
* Load/check the records with `_load.sh`.

Note the `|` because we are leaving out the value and just using the identifier.
```bash
curl 'http://hapi.fhir.org/baseR4/Organization?identifier=https://play.dhis2.org/dev/api/organisationUnits|' | jq .
# this query won't work on the alphora server because the feature may be off
# curl 'https://cloud.alphora.com/sandbox/r4/cqm/fhir/Organization?identifier=https://play.dhis2.org/dev/api/organisationUnits|' | jq .
```

```
"identifier": [
    {
        "system": "https://github.com/synthetichealth/synthea",
        "value": "ef58ea08-d883-3957-8300-150554edc8fb"
    },
    {
        "system": "https://play.dhis2.org/dev/api/organisationUnits",
        "value": "xWIyicUgscN"
    }
],
```