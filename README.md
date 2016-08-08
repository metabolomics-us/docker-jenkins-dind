# Jenkins DinD (Docker in Docker)
This Jenkins Docker image provides Docker inside itself, which allows you to run any Docker container in your Jenkins build script.  It also optionally allows the ability to push to a self-signed secure private registry.

Run it with mounted directory from host:

```
docker run --name jenkins-dind --privileged -d -p 8080:8080 -v /your/path:/var/lib/jenkins jenkins-dind
```

This Docker image is based on [jpetazzo/dind](https://registry.hub.docker.com/u/jpetazzo/dind/) instead of the offical [Jenkins](https://registry.hub.docker.com/u/library/jenkins/). Supervisord is used to make sure everything has proper permission and lanuch in the right order. Morever, [Docker Compose](https://github.com/docker/compose) is available for launching multiple containers inside the CI.