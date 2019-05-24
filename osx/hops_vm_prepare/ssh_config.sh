#!/usr/local/bin/bash
set -e

BASH_MAJOR_VERSION=$(echo ${BASH_VERSION} | cut -d'.' -f1)
if [ ${BASH_MAJOR_VERSION} -lt 4 ] ; then
  echo "You need at least bash 4 to run this script"
  exit 1
fi
MY_PATH=`dirname "$0"`
MY_PATH=`( cd $MY_PATH && pwd )`
PARAM_FILE=${MY_PATH}/ssh_config_params.sh
EXEC_FILE=${MY_PATH}/ssh_config.sh

if [ ! -f ${PARAM_FILE} ]; then
  echo "File ${PARAM_FILE} does not exist."
  exit 1
fi

if [ ! -f ${EXEC_FILE} ]; then
  echo "File ${EXEC_FILE} does not exist. Wrong run location"
  exit 1
fi

. ${PARAM_FILE}

#save old config
cp ${SSH_CONFIG_FILE} ${SSH_CONFIG_FILE}_save
scp ${VM_SERVER_ALIAS}:${VM_DIR}/Vagrantfile .
#ssh port
SSH_PORT=$(ggrep -Po '{\K[^}]*' Vagrantfile | grep 22 | cut -d':' -f3 | cut -d'>' -f2)
#delete previous ssh entry
SSH_ENTRY=$(cat ${SSH_CONFIG_FILE} | ggrep -n "Host ${SSH_ALIAS}" | cut -d':' -f1 | wc -l)
if [ ${SSH_ENTRY} == 2 ]; then
  SSH_BEGIN=$(cat ${SSH_CONFIG_FILE} | ggrep -n "Host ${SSH_ALIAS}" | cut -d':' -f1 | gsed -n 1p)
  SSH_END=$(cat ${SSH_CONFIG_FILE} | ggrep -n "Host ${SSH_ALIAS}" | cut -d':' -f1 | gsed -n 2p)
  gsed -i "${SSH_BEGIN},${SSH_END}d" ${SSH_CONFIG_FILE}
  echo "Old ${SSH_ALIAS} deleted from ${SSH_CONFIG_FILE}"
elif [ ${SSH_ENTRY} == 0 ]; then
  echo "No ${SSH_ALIAS} entry detected in ${SSH_CONFIG_FILE}"
else
  echo "incomplete ${SSH_ALIAS} - please cleanup manually ${SSH_CONFIG_FILE} before re-running this script"
  exit 1
fi
#add new ssh entry
echo "Host ${SSH_ALIAS}" >> ${SSH_CONFIG_FILE}
echo "  Hostname ${VM_SERVER}" >> ${SSH_CONFIG_FILE}
echo "  User ${VM_USER}" >> ${SSH_CONFIG_FILE}
echo "  ProxyJump ${VM_PROXY}" >> ${SSH_CONFIG_FILE}
echo "  Port ${SSH_PORT}" >> ${SSH_CONFIG_FILE}
echo "#End Host ${SSH_ALIAS}" >> ${SSH_CONFIG_FILE}
echo "new ${SSH_ALIAS} added to your ${SSH_CONFIG_FILE}"

#pfwd ports
declare -A VM_PFWD_PORTS
for port in ${VM_PORTS[@]}; do 
  PFWD_PORTS[$port]=$(ggrep -Po '{\K[^}]*' Vagrantfile | grep ${port} | cut -d':' -f3 | cut -d'>' -f2)
done

#delete previous pfwd entry
PFWD_ENTRY=$(cat ${SSH_CONFIG_FILE} | ggrep -n "Host ${SSH_PFWD_ALIAS}" | cut -d':' -f1 | wc -l)
if [ ${PFWD_ENTRY} == 2 ]; then
  SSH_PFWD_BEGIN=$(cat ${SSH_CONFIG_FILE} | ggrep -n "Host ${SSH_PFWD_ALIAS}" | cut -d':' -f1 | gsed -n 1p)
  SSH_PFWD_END=$(cat ${SSH_CONFIG_FILE} | ggrep -n "Host ${SSH_PFWD_ALIAS}" | cut -d':' -f1 | gsed -n 2p)
  gsed -i "${SSH_PFWD_BEGIN},${SSH_PFWD_END}d" ${SSH_CONFIG_FILE}
  echo "Old ${SSH_PFWD_ALIAS} deleted from ${SSH_CONFIG_FILE}"
elif [ ${PFWD_ENTRY} == 0 ]; then
  echo "No ${SSH_PFWD_ALIAS} entry detected in ${SSH_CONFIG_FILE}"
else
  echo "incomplete ${SSH_PFWD_ALIAS} - please cleanup manually ${SSH_CONFIG_FILE} before re-running this script"
  exit 1
fi

#add new pfwd entry
echo "Host ${SSH_PFWD_ALIAS}" >> ${SSH_CONFIG_FILE}
echo "  Hostname ${VM_SERVER}" >> ${SSH_CONFIG_FILE}
echo "  User ${VM_SERVER_USER}" >> ${SSH_CONFIG_FILE}
echo "  ProxyJump ${VM_PROXY}" >> ${SSH_CONFIG_FILE}
for port in ${VM_PORTS[@]}; do 
  echo "  LocalForward ${port} localhost:${PFWD_PORTS[$port]}" >> ${SSH_CONFIG_FILE}
done
echo "#End Host ${SSH_PFWD_ALIAS}" >> ${SSH_CONFIG_FILE}
echo "new ${SSH_PFWD_ALIAS} added to your ${SSH_CONFIG_FILE}"
rm Vagrantfile
