#!/bin/sh
# image.sh -- Manage the FreeBSD VM image
# Chapter 20: From Server to Laptop
# Equivalent of: docker pull (for the base system)

JFERRY_VERSION="15.0-RELEASE"
JFERRY_DIR="${HOME}/.jferry"

detect_arch() {
    case "$(uname -m)" in
        arm64|aarch64) echo "aarch64" ;;
        *)             echo "amd64" ;;
    esac
}

JFERRY_ARCH="$(detect_arch)"
JFERRY_BASE="FreeBSD-${JFERRY_VERSION}"

case "${JFERRY_ARCH}" in
    aarch64) JFERRY_IMAGE="${JFERRY_BASE}-arm64-aarch64-zfs.qcow2" ;;
    amd64)   JFERRY_IMAGE="${JFERRY_BASE}-amd64-zfs.qcow2" ;;
esac

JFERRY_URL="https://download.freebsd.org/releases/VM-IMAGES/${JFERRY_VERSION}/${JFERRY_ARCH}/Latest/${JFERRY_IMAGE}.xz"
JFERRY_IMAGE_PATH="${JFERRY_DIR}/${JFERRY_IMAGE}"

check_image() {
    [ -f "${JFERRY_IMAGE_PATH}" ]
}

create_image() {
    mkdir -p "${JFERRY_DIR}"
    echo "Detected architecture: ${JFERRY_ARCH}"
    echo "Downloading ${JFERRY_IMAGE}..."
    curl -Lo "${JFERRY_DIR}/${JFERRY_IMAGE}.xz" "${JFERRY_URL}"
    xz -d "${JFERRY_DIR}/${JFERRY_IMAGE}.xz"
    echo "Image ready: ${JFERRY_IMAGE_PATH}"
}
