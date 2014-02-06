## Plaza Playbook
This is an ansible playbook to provision the Plaza environment on OpenStack.

### Preconditions
This playbook provisions existing computing instances and does not instantiate the machines themselves. This means that it is required to fill in the provided inventory file with the specific details of the virtual machine cluster instantiation.

This playbook expects all computing instances to be Debian! The playbook has been tested against Debian 7.3.0 "Wheezy".

The playbook expects a specific set of virtual machines for the environment, this set is as follows:

  - One instance to act as the software load balancer
  - Two instances to act as drupal webservers
  - Two instances to support the NFS HA cluster
  - Two instances to support the MySQL HA cluster

See the provided inventory file for more details.

If the target environment for this playbook is deployed in OpenStack, it is necessary to define a series of role variables:

  - On the `ha-disk` role:
    + **OS_PROJECT** - The name of the OpenStack project.
    + **OS_USERNAME** - The user name of one management member of the OpenStack project.
    + **OS_PASSWORD** - The password matching the above user name.
    + **ROUTER_PUBLIC_IP** - The public interface's IP on the OpenStack network router

  - On both the `nfs` and `mysql` roles:
    + **OS_FLOATIP** - The allocated floating IP for the HA cluster.

If the target environment is **not** OpenStack, remember to set the `IS_TARGET_OPENSTACK` variable to `False` in `vars/main.yml`.

It is required, for the four machines supporting the two HA clusters to have a cinder volume attached. The playbook defaults the location of this volume on the `vdb` block device. It is highly recommended to run the `list-partitions` playbook to identify the actual device location on each of the virtual machines and override the defaults with the `block_device` variable. The `list-partitions` playbook will report unpartitioned devices as skipped results.

## NOTES:
This playbook is written to connect to the target machines under the `debian` user. It is possible to override this on a per-host basis on the inventory file via the `ansible_ssh_user` variable.

The ha-disk role provides an `hb_auth` variable for the NFS and MySQL clusters; these are for heartbeat authorization and, although it works as-is, it is recommended to override it on the inventory file setting it to any random string and preferably defining different values for the nfs and mysql host groups.

Remember to override your system's default inventory location by running `ansible-playbook` with the `-i` flag.

## TODO:

  - Make conditional provisioning to support non OpenStack Deployments.
