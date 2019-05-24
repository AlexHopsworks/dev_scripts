#!/bin/bash
#
SSH_CONFIG_FILE=~/.ssh/config
#
VM_USER=root
VM_SERVER_USER=aaor
VM_SERVER=bbc5.sics.se
VM_SERVER_ALIAS=aaor_bbc5
VM_PROXY=aaor_bbc1
VM_DIR=/home/aaor/new_prov
VM_PORTS=(3306 9090 8181 4848)
#
SSH_PFWD_ALIAS=pfwd_notls_1
SSH_ALIAS=run_notls_1