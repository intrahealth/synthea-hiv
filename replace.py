#!/usr/bin/env python3

from pathlib import Path
try:
  import simdjson as json
except:
  import json
import random

source = Path.home()/'src/github.com' 

dis = source / 'intrahealth/synthea-hiv'
# get the sierra leone playground mcsd
org_units = dis / 'orgUnits.json'
mcsd = open(org_units, 'rb').read()
stuff = json.loads(mcsd)
listorg = []
for s in stuff['entry']:
    if s['resource']['resourceType'] == 'Organization':
        # this appends the dhis2 system and the resource.id, because the dhis2 identifier systems are duplicates.
        # todo: revisit this, and append all items
        listorg.append({'system': 'https://play.dhis2.org/dev/api/organisationUnits', 'value': s['resource']['id']})
# print(listorg)

preparedpath = dis / 'preparedsynthea.json'
dis_output = source / 'intrahealth/synthea-hiv' / 'output/fhir'
file = Path(dis_output).glob('hospital*.json')
# file = Path(dis_output).glob('*.json')
for i in file:
    print(i.name, i.stem)
    a = open(i, 'rb').read()
    h = json.loads(a)
    for entry in h['entry']:
        if entry['resource']['resourceType'] == 'Organization':
            # start loop of listorg to assign dhis2 org units
            # this just takes random one at a time, its a hack
            entry['resource']['identifier'].append(random.choice(listorg))
            # print(entry['resource']['identifier'])
    # print(h)

    with open(preparedpath, 'w') as f:
        json.dump(h, f, indent=2)