#!/bin/bash
# Make sure you configure your VM_PROXY and VM_SERVER_ALIAS manually in your config file
SSH_CONFIG_FILE=~/.ssh/config
# Alias used in the ssh config file for port forwarding
#SSH_PFWD_ALIAS=pfwd_notls
SSH_PFWD_ALIAS=pfwd_tls
# Alias used in the ssh config file for ssh-ing - define one alias per vm host
declare -A SSH_ALIASES 
#SSH_ALIASES[config]=run_notls
SSH_ALIASES[hopsworks0]=run_tls_0
SSH_ALIASES[hopsworks1]=run_tls_1
SSH_ALIASES[hopsworks2]=run_tls_2
# BBC machines are not directly accessible so we typically access them by proxies.
VM_SERVER_ALIAS=aaor_bbc5
# VM Chef Dir on VM_SERVER_ALIAS
#VM_DIR=/home/aaor/new_prov
VM_DIR=/home/aaor/tls_prov
#Server running your vm - used as Host in the ssh config entry
VM_SERVER=bbc5.sics.se
#User on the VM_SERVER - used as User in the ssh pfwd config entry
VM_SERVER_USER=aaor
#Proxy for BBC machines - used in pfwd config entry. You should configure this proxy beforehand
VM_PROXY=aaor_bbc1
#User in ssh proxy entry - You will be sshed as this user in your vm.
VM_USER=root
#Port that you want to have port forwarded to your vm.
VM_PORTS=(3306 9090 8181 4848)