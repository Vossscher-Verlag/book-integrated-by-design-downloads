#!/bin/sh
# share.sh -- Mount jail data onto the host
# Chapter 20: From Server to Laptop
# Equivalent of: docker run -v /host:/container

JFERRY_CONF="jferry.conf"
JFERRY_JAIL_PATH="/usr/local/jails"

create_share() {
    conf="${1}/${JFERRY_CONF}"
    [ -f "${conf}" ] || return 0

    mount_base="${1}/jferry"
    mkdir -p "${mount_base}"

    while read -r jail jail_path local_name; do
        case "${jail}" in \#*|"") continue ;; esac
        target="${mount_base}/${local_name}"
        mkdir -p "${target}"
        mount -t nfs \
            -o vers=4,port="${JFERRY_NFS_PORT}" \
            "localhost:${JFERRY_JAIL_PATH}/${jail}${jail_path}" \
            "${target}"
        echo "Mounted: ${jail}:${jail_path} -> ${local_name}/"
    done < "${conf}"
}

delete_share() {
    mount_base="${1}/jferry"
    [ -d "${mount_base}" ] || return 0

    for dir in "${mount_base}"/*/; do
        [ -d "${dir}" ] && umount "${dir}" 2>/dev/null
    done
}
