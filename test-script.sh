#!/usr/bin/env bash
current_version=$(mvn -N help:evaluate -q -Dexpression='project.version' -DforceStdout=true)
current_version=$1
echo "Building classifiers for ${current_version}"
URL="https://mcollovati.jfrog.io/artifactory/api/search/gavc?g=com.github.mcollovati.vertx&a=vaadin-flow-sockjs&c=vaadin-*&v=${current_version}&repos=vertx-vaadin-releases"
JQ_FILTER='.results[].uri | (match("^.*/vaadin-flow-sockjs-'${current_version}'-vaadin-(?<version>.*)\\.jar$") | .captures[].string )'

__classifiers=$(curl -s "${URL}" | jq --raw-output "${JQ_FILTER}" | sort -r)
echo "Existing classifiers for ${current_version}:"
echo "${__classifiers[@]}"
echo
declare -A _existing_versions
for classifier in ${__classifiers}; do
  _existing_versions[${classifier}]=1
done


vaadin_platform=18
__versions=$(curl -s "https://search.maven.org/solrsearch/select?q=g:com.vaadin+AND+a:vaadin-core+AND+v:${vaadin_platform}.*&rows=10&core=gav" | jq -r '.response.docs[].v')

echo "Latest Vaadin version for ${vaadin_platform}:"
echo "${__versions[@]}"
echo

for version in ${__versions}; do
  echo "Checking v ${version}"
  if [[ ${_existing_versions[$version]} ]]; then
    echo "Classifier vaadin-${version} already exists for version ${current_version}"
  else
    echo "Building classifier vaadin-${version} for version ${current_version}"
  fi

done