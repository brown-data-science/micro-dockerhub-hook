#!/bin/bash
echo $1

REPOSITORY=browndatasci
IMAGE_NAME=micro-dockerhub-hook

# Bail if we're on a dirty git tree
if ! git diff-index --quiet HEAD; then
    echo "You have uncommited changes. Please commit them before building and"
    echo "populating. This helps ensure that all docker images are traceable"
    echo "back to a git commit."
    exit 1
fi

#Get the tag from 
GIT_REV=$(git log -n 1 --pretty=format:%h)
TAG="${GIT_REV}"

echo "Tag: ${TAG}"

if [ "$1" == "build-and-push" ]; then
    docker build -f Dockerfile --tag=${REPOSITORY}/${IMAGE_NAME}:${TAG} .
    docker push ${REPOSITORY}/${IMAGE_NAME}:${TAG}
    docker tag ${REPOSITORY}/${IMAGE_NAME}:${TAG} ${REPOSITORY}/${IMAGE_NAME}:latest
    docker push ${REPOSITORY}/${IMAGE_NAME}:latest
    echo "Pushed ${REPOSITORY}/${IMAGE_NAME}:${TAG} and :latest"
elif [ "$1" == "run-dev" ]; then
    docker run -p 3000:3000 -e TOKEN=123abc -v /maintain/docker:/src/scripts -v /var/run/docker.sock:/var/run/docker.sock --name micro-dockerhub-hook maccyber/micro-dockerhub-hook
 --name ${IMAGE_NAME} ${REPOSITORY}/${IMAGE_NAME}:latest
elif [ "$1" == "rm" ]; then
    docker rm ${IMAGE_NAME}
else
    echo "First argument must be one of the following strings: build-and-push, run-dev, rm"
fi