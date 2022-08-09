#/usr/bin/env bash


cd $HOME/src/github.com/intrahealth/synthea-hiv
python3 $HOME/src/github.com/intrahealth/synthea-hiv/replace.py
cd $HOME/src/github.com/intrahealth/synthea-hiv

# cat << %% | ssh -o RequestTTY=no richard@zbook.local
#     sudo apt update
#     sudo apt upgrade -y
#     sudo apt auto-remove -y
# %%
