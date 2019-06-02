#!/bin/bash
set -e

MY_PATH=`dirname "$0"`
MY_PATH=`( cd $MY_PATH && pwd )`
PARAM_FILE=${MY_PATH}/deploy_private_key_params.sh
EXEC_FILE=${MY_PATH}/deploy_private_key.sh

if [ ! -f ${PARAM_FILE} ]; then
  echo "File ${PARAM_FILE} does not exist."
  exit 1
fi

if [ ! -f ${EXEC_FILE} ]; then
  echo "File ${EXEC_FILE} does not exist. Wrong run location"
  exit 1
fi

. ${PARAM_FILE}

DATE=`date '+%Y_%m_%d_%H_%M_%S'`
for KEY_NAME in ${!VM_KEYS[@]}; do
  for VM in ${!VM_USERS[@]}; do
    echo "vm:${VM} user:${VM_USERS[${VM}]} key:${KEY_NAME}"
    scp ${VM_KEYS[${KEY_NAME}]} ${VM}:/tmp
    #setup - .ssh folder and authorized_keys file 
    #add key to authorized_keys file if it doesn't exist already
    ssh ${VM} "
    sudo -u ${VM_USERS[${VM}]} -H -s eval '([ -d ~/.ssh ] || ( mkdir ~/.ssh && chmod 700 ~/.ssh )) && \
      (([ -f ~/.ssh/id_rsa ] && mv ~/.ssh/id_rsa ~/.ssh/id_rsa_${DATE}) || : ) && \
      cp /tmp/id_rsa ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa'"
  done
done