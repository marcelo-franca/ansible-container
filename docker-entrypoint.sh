#!/bin/bash

ansible_configure() {

  if [ -f $HOME/ansible.cfg ]; then
      sed -i 's/^#host_key_checking\ =\ False/host_key_checking\ =\ False/g' \
      $HOME/ansible.cfg
      touch $HOME/.ansible_configured
      /bin/bash
  fi
}

if [ -f $HOME/.ansible_configured ]; then
    echo "Ansible been configured"
    /bin/bash
else
    ansible_configure;
fi