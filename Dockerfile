FROM ubuntu:16.04
MAINTAINER Sajjan Singh Mehta <sajjan.s.mehta@gmail.com>

# References:
#   https://hub.docker.com/_/docker/
#   https://hub.docker.com/r/roberto/docker-jenkins-dind/
#   https://hub.docker.com/r/jpetazzo/dind/

# Let's start with some basic stuff.
RUN apt-get update -qq && \
	apt-get install -qqy apt-transport-https ca-certificates curl wget lxc iptables vim software-properties-common

# Install JDK and Maven
RUN apt-get install -qqy openjdk-8-jdk maven

# Install syslog-stdout
RUN apt-get -qqy install python-setuptools python3-pip && \
	pip3 install --upgrade pip && \
    easy_install syslog-stdout supervisor-stdout

# Install Docker from Docker Inc. repositories.
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
RUN apt-get update && \
    apt-get install -qqy docker-ce

# Install Docker Compose
ENV DOCKER_COMPOSE_VERSION 1.17.0
RUN curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# Install the wrapper script
ENV DIND_COMMIT 3b5fac462d21ca164b3778647420016315289034

RUN wget "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -O /usr/local/bin/dind && \
	chmod +x /usr/local/bin/dind

ADD includes/sh/wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Install Jenkins
RUN wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN apt-get update && apt-get install -y zip supervisor jenkins && rm -rf /var/lib/apt/lists/*
RUN usermod -a -G docker jenkins
ENV JENKINS_HOME /var/lib/jenkins
VOLUME /var/lib/jenkins

# Get plugins.sh tool from official Jenkins repo
ENV JENKINS_UC https://updates.jenkins.io

RUN curl -o /usr/local/bin/plugins.sh \
  https://raw.githubusercontent.com/jenkinsci/docker/75b17c48494d4987aa5c2ce7ad02820fda932ce4/plugins.sh && \
  chmod +x /usr/local/bin/plugins.sh

# Install Compass
RUN apt-get update -qq && \
    apt-get install -qqy ruby-compass

# Install npm
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g serverless serverless-python-requirements

# Install awscli
RUN pip install awscli

# Configure bower to allow running as root
RUN echo '{ "allow_root": true }' > /root/.bowerrc

# Configure the language and encoding
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Define our volume mount point
VOLUME /var/lib/docker

# Add additional scripts and configurations
ADD includes/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD includes/sh/docker-entrypoint /
ADD includes/sh/registry-certificate /usr/local/bin/
ADD includes/sh/fix_volume_ownership /
RUN chmod +x /docker-entrypoint /usr/local/bin/registry-certificate /fix_volume_ownership

# Expose port 8080
EXPOSE 8080

# Define our entrypoint script
ENTRYPOINT ["/docker-entrypoint"]

# Start the supervisor daemon
CMD ["/usr/bin/supervisord"]
