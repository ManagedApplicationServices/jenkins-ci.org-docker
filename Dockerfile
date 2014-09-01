FROM ubuntu:14.04

RUN echo "1.565.1" > .lts-version-number

RUN apt-get update && apt-get install -y nano wget git curl zip
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-7-jdk
RUN apt-get update && apt-get install -y maven ant ruby rbenv make

RUN wget -q -O - http://pkg.jenkins-ci.org/debian-stable/jenkins-ci.org.key | sudo apt-key add -
RUN echo deb http://pkg.jenkins-ci.org/debian-stable binary/ >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y jenkins
RUN mkdir -p /var/jenkins_home && chown -R jenkins /var/jenkins_home
ADD init.groovy /tmp/WEB-INF/init.groovy
RUN cd /tmp && zip -g /usr/share/jenkins/jenkins.war WEB-INF/init.groovy
ADD ./jenkins.sh /usr/local/bin/jenkins.sh
RUN chmod +x /usr/local/bin/jenkins.sh

# configure ssh
RUN mkdir /var/lib/jenkins/.ssh
ADD ./.ssh /var/lib/jenkins/.ssh
RUN chown jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa
RUN ls -al /var/lib/jenkins/.ssh
RUN curl https://raw.githubusercontent.com/ManagedApplicationServices/dotfiles/master/.bashrc > /.bashrc

#user
USER jenkins
RUN whoami
RUN echo $HOME

# VOLUME /var/jenkins_home - bind this in via -v if you want to make this persistent.
ENV JENKINS_HOME /var/jenkins_home

# define url prefix for running jenkins behind Apache (https://wiki.jenkins-ci.org/display/JENKINS/Running+Jenkins+behind+Apache)
ENV JENKINS_PREFIX /

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

CMD ["/usr/local/bin/jenkins.sh"]

RUN echo "Copy this key contents to Github:"
RUN cat /var/lib/jenkins/.ssh/id_rsa.pub
