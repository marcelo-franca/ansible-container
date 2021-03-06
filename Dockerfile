FROM debian:buster-slim

LABEL maintainer="<marcelo.frneves@gmail.com>"
LABEL name="Marcelo França"
LABEL app="ansible"
ENV ANSIBLE_USER "ansible"
ENV LOCAL_SCRIPTS="/usr/local/src"
ENV ANSIBLE_LOCAL_BIN="/etc/ansible/.local"
ENV PATH="$LOCAL_SCRIPTS/:$ANSIBLE_LOCAL_BIN/bin:$PATH"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y
  
RUN apt-get install gnupg2 gnupg1 -y \
    && echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list


RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
RUN apt-get update \
    && apt-get install ansible python-apt git sudo unzip python-pip python3 python3-pip  -y

COPY ./docker-entrypoint.sh /usr/local/src/docker-entrypoint.sh
COPY ./config/aws/awscliv2.zip /tmp/awscliv2.zip

RUN useradd -M -d /etc/ansible ${ANSIBLE_USER} -s /bin/bash \
  && if [ -z "${PASSWORD}" ]; then \
  export PASSWORD=`cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c${1:-16}` && \
  echo -n "\n\n===================== ANSIBLE ==========================\n \
  Ansible admin user: ${ANSIBLE_USER} \n \
  Ansible password: ${PASSWORD}\n\n" > /dev/stdout; \
  fi \
  && (echo ${PASSWORD} ; echo ${PASSWORD} ) | passwd ${ANSIBLE_USER} \
  && gpasswd -a ${ANSIBLE_USER} sudo \
  && chmod 700 ${LOCAL_SCRIPTS}/*.sh \
  && echo "${ANSIBLE_USER} ALL=(ALL) NOPASSWD: ANSIBLE" >> /etc/sudoers \
  && mkdir /etc/ansible/playbooks \
  && chown ${ANSIBLE_USER}:${ANSIBLE_USER} /etc/ansible -R \
  && chown ${ANSIBLE_USER}:${ANSIBLE_USER} ${LOCAL_SCRIPTS}/* -R

## Configuring ansible.cfg
RUN sed -i 's/^#host_key_checking\ =\ False/host_key_checking\ =\ False/g' \
  /etc/ansible/ansible.cfg \
  && touch /etc/ansible/.ansible_configured
## Install AWS cli
RUN unzip -q /tmp/awscliv2.zip -d /tmp \
  && ./tmp/aws/install

RUN apt-get clean autoclean \
  && apt-get autoremove \
  && rm -rf /var/lib/{apt,cache,log}/ \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/aws*

RUN export VERSION=$(ansible --version | head -n 1 | tr -d '[[:alpha:][ ]]') \
  && echo -n $VERSION > /tmp/.ansible_version


VOLUME [ "/etc/ansible/playbooks" ]

WORKDIR /etc/ansible
USER ${ANSIBLE_USER}

ENTRYPOINT []
CMD ["docker-entrypoint.sh" ]
