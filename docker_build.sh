#!/bin/bash

docker build -t jenkins-dind --no-cache .
docker tag docker tag jenkins-dind eros.fiehnlab.ucdavis.edu/jenkins-dind
docker push eros.fiehnlab.ucdavis.edu/jenkins-dind