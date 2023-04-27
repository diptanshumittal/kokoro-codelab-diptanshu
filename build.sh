#!/bin/bash

echo $KOKORO_PYTHON_COMMAND
which python3
which python3
pip install -r requirements.txt

sty=$(curl -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" \
 https://api.github.com/repos/googleapis/google-cloud-go/pulls/7687/files | \
 jq -r 'map(select(.filename == ".release-please-manifest-individual.json" or .filename == ".release-please-manifest-submodules.json") | .patch)[0]' | 
 awk '/^[+]/{print substr($2,2, length($2)-3)}')

echo $sty

products=($sty)

echo ${products[@]}

if [ "$1" == "release" ]; then
  javac -g:none Hello.java
else
  javac Hello.java
fi
java Hello



set -eo pipefail

function now { date +"%Y-%m-%d %H:%M:%S" | tr -d '\n' ;}
function msg { println "$*" >&2 ;}
function println { printf '%s\n' "$(now) $*" ;}


# Populates requested secrets set in SECRET_MANAGER_KEYS from service account:
# kokoro-trampoline@cloud-devrel-kokoro-resources.iam.gserviceaccount.com
SECRET_LOCATION="${KOKORO_GFILE_DIR}/secret_manager"
msg "Creating folder on disk for secrets: ${SECRET_LOCATION}"
mkdir -p ${SECRET_LOCATION}
for key in $(echo ${SECRET_MANAGER_KEYS} | sed "s/,/ /g")
do
  msg "Retrieving secret ${key}"
  docker run --entrypoint=gcloud \
    --volume=${KOKORO_GFILE_DIR}:${KOKORO_GFILE_DIR} \
    gcr.io/google.com/cloudsdktool/cloud-sdk \
    secrets versions access latest \
    --project cloud-devrel-kokoro-resources \
    --secret ${key} > \
    "${SECRET_LOCATION}/${key}"
  if [[ $? == 0 ]]; then
    msg "Secret written to ${SECRET_LOCATION}/${key}"
  else
    msg "Error retrieving secret ${key}"
  fi
done
