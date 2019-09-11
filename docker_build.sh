#!/bin/bash

docker build -t jenkins-dind .
docker tag jenkins-dind eros.fiehnlab.ucdavis.edu/jenkins-dind
docker push eros.fiehnlab.ucdavis.edu/jenkins-dind