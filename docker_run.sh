#!/bin/bash

docker rm jenkins-dind
docker run --name jenkins-dind -d --privileged=true -p 30080:8080 -e "TZ=America/Los_Angeles" -v /opt/jenkins:/var/lib/jenkins jenkins-dind
