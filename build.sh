#!/bin/bash

sty=$(curl -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" \
 https://api.github.com/repos/googleapis/google-cloud-go/pulls/7687/files | \
 jq -r 'map(select(.filename == ".release-please-manifest-individual.json" or .filename == ".release-please-manifest-submodules.json") | .patch)[0]' | 
 awk '/^[+]/{print substr($2,2, length($2)-3)}')

echo $sty

products=($(curl -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" \
 https://api.github.com/repos/googleapis/google-cloud-go/pulls/7687/files | \
 jq -r 'map(select(.filename == ".release-please-manifest-individual.json" or .filename == ".release-please-manifest-submodules.json") | .patch)[0]' | \
 awk '/^[+]/{print substr($2,2, length($2)-3)}'))

echo $products

if [ "$1" == "release" ]; then
  javac -g:none Hello.java
else
  javac Hello.java
fi
java Hello
