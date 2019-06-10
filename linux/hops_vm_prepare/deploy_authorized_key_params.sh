#!/bin/bash
#key name - key file
declare -A VM_KEYS 
VM_KEYS[work]=~/.ssh/id_rsa.pub
#vm alias - vm user
#vm alias as defined in the ssh config 
#vm user - the user on the vm that the key should be installed on
#the alias might be configured to ssh as a different user than the one that gets the keys installed
#if the users are not the same, make sure the login user can impersonate the other user
declare -A VM_USERS 
VM_USERS[run_notls_vagrant]=root