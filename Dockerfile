FROM debian:buster-slim

ARG VERSION

LABEL maintainer="<marcelo.frneves@gmail.com>"
LABEL name="Marcelo França"
LABEL version="${VERSION}"
ENV ANSIBLE_USER "ansible"


RUN apt-get update && apt-get upgrade -y \
  && apt-get install gnupg2 gnupg1 -y \
  && echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> \
  /etc/apt/sources.list

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 \
  && apt-get update \
  && apt-get install ansible --no-install-recommends --no-install-suggests -y

RUN useradd -M -d /etc/ansible ${ANSIBLE_USER} -s /bin/bash \
  && if [ -z "${PASSWORD}" ]; then \
  export PASSWORD=`cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c${1:-16}` && \
  echo -n "\n\n===================== ANSIBLE ==========================\n \
  Ansible admin user: ${ANSIBLE_USER} \n \
  Ansible password: ${PASSWORD}\n\n" > /dev/stdout; \
  fi \
  && (echo ${PASSWORD} ; echo ${PASSWORD} ) | passwd ${ANSIBLE_USER}


RUN apt-get clean autoclean \
  && apt-get autoremove \
  && rm -rf /var/lib/{apt,cache,log}/ \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /etc/ansible
#USER ${ANSIBLE_USER}
