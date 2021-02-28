#!/usr/bin/env python3

"""
Cleans up a bug in subject.reference where cql evaluator won't link observations
"""

from pathlib import Path
import json
import os

basepath = Path('output_ig/fhir')
suffix = '.json'
for filename in basepath.iterdir():
    if filename.is_dir():
        print(filename.name)
        fz = filename.joinpath(filename.name).with_suffix(".json")
        data = json.loads(fz.read_bytes())
        dir2make = Path("output_ig_fix/fhir").joinpath(filename.name)
        try:
            dir2make.mkdir(parents=True, exist_ok=True)
            os.mkdir(dir2make)
        except:
            print("oopsie")
        for entry in data["entry"]:
            if entry["resource"]["resourceType"] == "Observation":
                print(entry["resource"]["subject"]["reference"])
                entry["resource"]["subject"]["reference"] = f"{filename.name}"
                print(entry["resource"]["subject"]["reference"])

        filename2 = dir2make / filename.name
        print("new", filename2)
        with open(filename2, 'w') as f:
            json.dump(data, f, ensure_ascii=False, indent=4)

        filename_replace_ext = filename2.with_suffix(".json")
        filename2.rename(filename_replace_ext)