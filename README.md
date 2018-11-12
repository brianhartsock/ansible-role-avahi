ansible.avahi
=========

[![Build Status](https://travis-ci.org/brianhartsock/ansible-role-avahi.svg?branch=master)](https://travis-ci.org/brianhartsock/ansible-role-avahi)

Ansible role to install and configure [Avahi](https://www.avahi.org). Avahi enables discoverable services in a network, specifically mirroring Apple Bonjour behavior allow Mac's to discover services in a Linux machine.

Requirements
------------

This role has been tested on Ubuntu 16.04 and should work on most modern Debian installations.

The role will need `sudo` privileges so it should be run with `become: True` or a user with sufficient default privileges to install and configure packages.

Role Variables
--------------

The following variables are defined in `defaults/main.yml` and can be used to further configure Avahi services. `avahi_services` is the most important variable which defines which services are advertised over mDNS.

```yaml
# List of service definitions.
avahi_services:
  # Name of the file, /etc/avahi/services/afpd.service
  - name: afpd
    # List of services                  
    services:
      # Service type, port, and txt records.
      - type: _afpower._tcp
        port: 548
      - type: _device-info._tcp
        port: 0
        txt_records:
          - model=Xserve

# Replace wildcards in the service definition (i.e. %h -> hostname)
avahi_replace_wildcards: yes

# Network name to be advertised
avahi_network_name: '%h'
```

Dependencies
------------

None

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - name: brianhartsock.avahi
           become: true

License
-------

MIT

Author Information
------------------

Created with love by [Brian Hartsock](http://blog.brianhartsock.com).

Helpful Links
-------------

- [Avahi Service Details](https://linux.die.net/man/5/avahi.service)
- [mDNS/Bonjour Bible](https://jonathanmumm.com/tech-it/mdns-bonjour-bible-common-service-strings-for-various-vendors/)
