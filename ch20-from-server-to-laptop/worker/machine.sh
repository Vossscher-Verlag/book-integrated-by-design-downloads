#!/bin/sh
# machine.sh -- Start and stop the FreeBSD VM
# Chapter 20: From Server to Laptop

JFERRY_RAM="2G"
JFERRY_CPUS="2"
JFERRY_SSH_PORT="2223"
JFERRY_NFS_PORT="12049"
JFERRY_PID="${HOME}/.jferry/qemu.pid"

# Display for the QEMU window. "none" runs the VM headless and daemonised,
# which is how you run it day to day -- you reach it over SSH. The very first
# boot is different: sshd is not enabled yet, so you need the console. Start it
# with a display for that one-time setup:
#   jferry firstboot              # picks cocoa on macOS, gtk on Linux
#   JFERRY_DISPLAY=gtk jferry firstboot
JFERRY_DISPLAY="${JFERRY_DISPLAY:-none}"

detect_accel() {
    case "$(uname -s)" in
        Darwin) echo "hvf" ;;
        Linux)  echo "kvm" ;;
        *)      echo "tcg" ;;
    esac
}

default_display() {
    case "$(uname -s)" in
        Darwin) echo "cocoa" ;;
        *)      echo "gtk" ;;
    esac
}

check_jferry() {
    [ -f "${JFERRY_PID}" ] && kill -0 "$(cat "${JFERRY_PID}")" 2>/dev/null
}

create_jferry() {
    case "${JFERRY_ARCH}" in
        aarch64)
            qemu_bin="qemu-system-aarch64"
            qemu_arch="-M virt,accel=$(detect_accel) -cpu host"
            qemu_bios="-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd"
            drive_if=",if=virtio"
            ;;
        amd64)
            qemu_bin="qemu-system-x86_64"
            qemu_arch="-accel $(detect_accel)"
            qemu_bios=""
            drive_if=""
            ;;
    esac

    qemu_fwd="hostfwd=tcp::${JFERRY_SSH_PORT}-:22"
    qemu_fwd="${qemu_fwd},hostfwd=tcp::${JFERRY_NFS_PORT}-:2049"

    # Headless runs as a background daemon with a PID file. A visible display
    # (first boot) runs in the foreground so you can use the console; it needs
    # no PID file, because you close it by powering the VM off. The unused
    # variable on either path simply vanishes when expanded unquoted.
    case "${JFERRY_DISPLAY}" in
        none) qemu_view="-daemonize -pidfile ${JFERRY_PID} -display none" ;;
        *)    qemu_view="-display ${JFERRY_DISPLAY}" ;;
    esac

    "${qemu_bin}" ${qemu_arch} ${qemu_bios} \
        -m "${JFERRY_RAM}" \
        -smp "${JFERRY_CPUS}" \
        -drive "file=${JFERRY_IMAGE_PATH},format=qcow2${drive_if}" \
        -netdev "user,id=net0,${qemu_fwd}" \
        -device virtio-net-pci,netdev=net0 \
        ${qemu_view}

    [ "${JFERRY_DISPLAY}" = "none" ] && echo "VM started (${JFERRY_ARCH})."
}

delete_jferry() {
    check_jferry || { echo "No running VM."; return; }
    kill "$(cat "${JFERRY_PID}")" && rm -f "${JFERRY_PID}"
    echo "VM stopped."
}
