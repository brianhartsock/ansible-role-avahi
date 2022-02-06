def test_avahi_installed(host):
    assert host.package('avahi-daemon').is_installed


# Ideally we could test is_running but can't because molecule is running in
# a docker container.
def test_service_enabled(host):
    assert host.service('avahi-daemon').is_enabled
