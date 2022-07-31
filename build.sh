#!/bin/bash
#
# -- Build PostGresDB in Docker Container with "World" Demo data

# ----------------------------------------------------------------------------------------------------------------------
# -- Variables ---------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------

if [[ "$OSTYPE" == "darwin"* ]]; then
  # MACOS Users
  # have to install another grep version (GNU Version) (not included in MacOS only BSD version is included)
  # with e.g. "brew install grep"
  GNU_GREP_TOOL="ggrep"
else
  GNU_GREP_TOOL="grep"
fi

BUILD_DATE="$(date -u +'%Y-%m-%d')"

SHOULD_BUILD="$(grep -m 1 build build.yml | ${GNU_GREP_TOOL} -o -P '(?<=").*(?=")')"
SHOULD_TAG="$(grep -m 1 tag build.yml | ${GNU_GREP_TOOL} -o -P '(?<=").*(?=")')"
SHOULD_PUSH="$(grep -m 1 push build.yml | ${GNU_GREP_TOOL} -o -P '(?<=").*(?=")')"

IMAGE_REPOSITORY="$(grep -m 1 imagerepository build.yml | ${GNU_GREP_TOOL} -o -P '(?<=").*(?=")')"

# ----------------------------------------------------------------------------------------------------------------------
# -- Functions----------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------

function cleanContainers() {
  container="$(docker ps -a | grep 'docker-postgres-world-db' | awk '{print $1}')"
  docker stop "${container}"
  docker rm "${container}"
}

function cleanImages() {

  if [[ "${SHOULD_BUILD}" == "true" ]]
  then
    docker rmi -f "$(docker images | grep -m 1 'docker-postgres-world-db' | awk '{print $3}')"
  fi

}

function buildImages() {

  if [[ "${SHOULD_BUILD}" == "true" ]]
  then
    docker build \
      --build-arg build_date="${BUILD_DATE}" \
      -f Dockerfile \
      -t docker-postgres-world-db:latest .
  fi

}

function tagImages() {

  docker tag docker-postgres-world-db:latest ${IMAGE_REPOSITORY}/docker-postgres-world-db:latest

}

function pushImages() {

  docker push ${IMAGE_REPOSITORY}/docker-postgres-world-db:latest

}

# ----------------------------------------------------------------------------------------------------------------------
# -- Main --------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------

cleanContainers;
cleanImages;
buildImages;

if [[ "${SHOULD_TAG}" == "true" ]]
then
  tagImages;
fi

if [[ "${SHOULD_PUSH}" == "true" ]]
then
  pushImages;
fi