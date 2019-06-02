## HOPS VM PREPARE
1. hops_vm_prepare/ssh_config.sh script

This config script inserts three entries into your .ssh/config file:
  * SSH_ALIAS - allows you to ssh directly in the vm with your own key to the set user
  * SSH_ALIAS_vagrant - sibling entry to the SSH_ALIAS - uses the insecure vagrant key to log into the vagrant user
  * SSH_PFWD_ALIAS - allows you to port forward usefull ports like 8181, 4848, 9090, 3306.

An example of the end result is:
```
Host vm_notls_vagrant
  Hostname bbc5.sics.se
  User vagrant
  ProxyJump aaor_bbc1
  Port  43451
  IdentityFile /Users/Alex/Documents/_Work/Code/alex-hopsworks/vagrant_key/insecure_private_key
#End Host vm_notls_vagrant
Host vm_notls
  Hostname bbc5.sics.se
  User root
  ProxyJump aaor_bbc1
  Port  43451
#End Host vm_notls
Host pfwd_notls
  Hostname bbc5.sics.se
  User aaor
  ProxyJump aaor_bbc1
  LocalForward 3306 localhost:26612
  LocalForward 9090 localhost:59573
  LocalForward 8181 localhost:34805
  LocalForward 4848 localhost:28927
#End Host pfwd_notls
```
You can now use
```
#ssh directly in the vm as user vagrant
ssh vm_notls_vagrant
```
```
#port forwards all the designated ports
ssh pfwd_notls
```
In order to enable the vm_notls ssh-ing you need to also run the deploy_authorized_key script:
```
hops_vm_prepare/deploy_authorized_key.sh
```

Running this script multiple times will regenerate this entries in your ssh config file - it will delete old entries and add the new ones. The new entry will be based on the Vagrantfile of your new vm. The script locates the Vagrantfile based on:
  * VM_SERVER_ALIAS - BBC machines are not directly accessible so we typically access them by proxies, thus I use the alias for ssh/scp and others.
    * this can be an alias in your ssh config file
    * user@host
  * VM_DIR - the location of the vm chef dir on the server
  
Check the ssh_config_params.sh for full parameters.
