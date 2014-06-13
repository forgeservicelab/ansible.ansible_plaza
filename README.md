## Plaza Playbook
This is an ansible playbook to provision the Plaza environment on OpenStack.

### Preconditions
This playbook provisions existing computing instances and does not instantiate the machines themselves. This means that it is required to fill in the provided inventory file with the specific details of the virtual machine cluster instantiation.

This playbook expects all computing instances to be Debian! The playbook has been tested against Debian 7.3.0 "Wheezy".

The playbook expects a specific set of virtual machines for the environment, this set is as follows:

  - At least one instance to act as the software load balancer; two are recommended.
  - Two instances to act as drupal webservers
  - Two instances to support the NFS HA cluster
  - Two instances to support the MySQL HA cluster

See the provided inventory file for more details.

If the target environment for this playbook is deployed in OpenStack, it is necessary to define a series of role variables:

  - On the `ha-disk` role:
    + `OS_PROJECT` - The name of the OpenStack project.
    + `OS_USERNAME` - The user name of one management member of the OpenStack project.
    + `OS_PASSWORD` - The password matching the above user name.

  - On the `loadbalancer`, `nfs` and `mysql` roles:
    + `OS_FLOATIP` - The allocated floating IP for the HA cluster.

If the target environment is **not** OpenStack, remember to set the `IS_TARGET_OPENSTACK` variable to `False` in `vars/main.yml`.

When deploying on OpenStack environments, this playbook runs some tasks on the control machine against OpenStack, make sure that the following python packages are installed on the control machine:

  - `python-novaclient`
  - `python-keystoneclient`
  - `python-neutronclient`
  - `httplib2.system_ca_certs_locater`

On OpenStack environments, special care needs to be taken with security groups as every VM specified above needs to talk to each other, this is usually allowed by the `default` security group. In addition, communication from the router needs to be allowed; the reason for this is that when a VM communicates with another via the latter's Floating IP it appears to come from the router's public interface. Allowing this kind of connection is easily accomplished by adding a rule to allow TCP connections from the router's public IP.

The `drupal` role configures an NFS mount on the webservers to host the drupal installation, the target NFS server IP is set via the `NFS_VIRTUAL_IP` role variable and it corresponds to the virtual or floating IP assigned to the NFS HA cluster. It also needs to connect to a MySQL backend whose IP is set via the `MySQL_VIRTUAL_IP` role variable which, likewise, corresponds to the virtual or floating IP assigned to the MySQL HA cluster.
Drupal webservers handle SSL termination, remember to add your `certificate.crt`, `certificate.key` and `certificate.chain.pem` files under `roles/drupal/files` and set the value of the `certificate_prefix` variable (in this example it would be `certificate`).

The `common` role defines the `web_domain` and is used by the `load-balancer` roles, this variable is unset by default. Read the roles' `README.md` files for more information on role variables.

It is required, for the four machines supporting the two HA clusters to have a cinder volume attached. The playbook defaults the location of this volume on the `vdb` block device. It is highly recommended to run the `list-partitions` playbook to identify the actual device location on each of the virtual machines and override the defaults with the `block_device` variable. The `list-partitions` playbook will report unpartitioned devices as skipped results.

## NOTES:
The variables described above are declared but undefined. Running the playbook without assigning proper values to them will cause it to malfunction or break. Please **read the roles' README** files before running the playbook.

This playbook is written to connect to the target machines under the `debian` user. It is possible to override this on a per-host basis on the inventory file via the `ansible_ssh_user` variable.

The ha-disk role provides an `hb_auth` variable for the NFS and MySQL clusters; these are for heartbeat authorization and, although it works as-is, it is recommended to override it on the inventory file setting it to any random string and preferably defining different values for the nfs and mysql host groups.

This playbook uses the ssh transport to clone git repositories. If your git ssh key is password protected, you'll need to add the following lines to your ansible configuration.

```
[ssh_connection]
ssh_args = -o ForwardAgent=yes
```

Remember to override your system's default inventory location by running `ansible-playbook` with the `-i` flag.

### Re-deploying drupal on an existing environment
No variables are needed to redeploy drupal on an already set up environment, all you need to do is run the following:

```
$ ansible-playbook -i plaza.inventory -t redeploy plaza.yml
```
