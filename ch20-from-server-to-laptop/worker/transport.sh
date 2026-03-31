#!/bin/sh
# transport.sh -- Move jails between server and laptop
# Chapter 20: From Server to Laptop
# Equivalent of: docker push / docker pull

JFERRY_SRV_PORT="2222"
JFERRY_DEV_PORT="2223"
JFERRY_KEY="${HOME}/.jferry/id_ed25519"
JFERRY_JAIL_ROOT="zroot/jails"

_ssh_server() {
    ssh -o StrictHostKeyChecking=no -p "${JFERRY_SRV_PORT}" root@localhost "$@"
}

_ssh_laptop() {
    ssh -o StrictHostKeyChecking=no \
        -i "${JFERRY_KEY}" \
        -p "${JFERRY_DEV_PORT}" root@localhost "$@"
}

create_transport() {
    jail_name="${1:?Usage: create_transport jail-name}"
    snap="${JFERRY_JAIL_ROOT}/${jail_name}@transport"

    _ssh_server "zfs snapshot ${snap}" \
        && _ssh_server "zfs send ${snap}" | _ssh_laptop "zfs recv ${snap%@*}" \
        && echo "Pulled: ${jail_name}"
}

push_transport() {
    jail_name="${1:?Usage: push_transport jail-name}"
    base="${JFERRY_JAIL_ROOT}/${jail_name}@transport"
    snap="${JFERRY_JAIL_ROOT}/${jail_name}@dev-push"

    _ssh_laptop "zfs snapshot ${snap}" \
        && _ssh_laptop "zfs send -i ${base} ${snap}" \
            | _ssh_server "zfs recv -F ${snap%@*}" \
        && echo "Pushed: ${jail_name}"
}

delete_transport() {
    jail_name="${1:?Usage: delete_transport jail-name}"
    _ssh_laptop "zfs destroy -r ${JFERRY_JAIL_ROOT}/${jail_name}" \
        && echo "Removed from laptop: ${jail_name}"
}

check_transport() {
    jail_name="${1:?Usage: check_transport jail-name}"
    echo "Server:"
    _ssh_server "zfs list -t snapshot ${JFERRY_JAIL_ROOT}/${jail_name}" 2>&1
    echo "Laptop:"
    _ssh_laptop "zfs list -t snapshot ${JFERRY_JAIL_ROOT}/${jail_name}" 2>&1
}
