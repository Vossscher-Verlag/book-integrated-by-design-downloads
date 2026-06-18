# Chapter 20 — jferry

`jferry` (the Jail Ferry) runs FreeBSD jails on your laptop using QEMU. Five
files of POSIX shell: an orchestrator and four workers.

```
jferry              Orchestrator (the CLI)
worker/image.sh     Download the FreeBSD VM image      (docker pull)
worker/machine.sh   Start and stop the VM              (docker start/stop)
worker/share.sh     Mount jail data over NFS           (docker run -v)
worker/transport.sh Move jails between server and VM   (docker push/pull)
jferry.conf         Which jail paths to mount (per project)
```

## Requirements

- QEMU. On macOS: `brew install qemu`. On Linux (Debian/Ubuntu):
  `sudo apt install qemu-system-x86`.
- On Apple Silicon, `machine.sh` expects the UEFI firmware at
  `/opt/homebrew/share/qemu/edk2-aarch64-code.fd` (installed by the QEMU
  package). Adjust the path if your Homebrew prefix differs.

## First boot (do this once)

The official FreeBSD VM image ships locked down: `sshd` is not enabled, and
there is no key installed. Before `jferry` can talk to the VM over SSH, you
need the **console** once, to enable `sshd`, install your key, and turn on the
NFS server.

Day-to-day, the VM runs headless (no window) because you reach it over SSH.
For this one-time setup you need a display, so use the `firstboot` command:

```
./jferry firstboot
```

This downloads the image if necessary and starts the VM **in a window**
(`cocoa` on macOS, `gtk` on Linux; override with `JFERRY_DISPLAY=...`). The
command runs in the foreground — the QEMU window is your console.

In that console, log in as `root` (no password on the stock image) and
configure SSH and NFS:

```
# Enable and start sshd
sysrc sshd_enable=YES
service sshd start

# Install your public key (generate it on the host first:
#   ssh-keygen -t ed25519 -f ~/.jferry/id_ed25519 -N "" -C "jferry")
mkdir -p /root/.ssh && chmod 700 /root/.ssh
echo "ssh-ed25519 AAAA... jferry" > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Enable the NFS server and export the jail directory
sysrc nfs_server_enable=YES
sysrc nfsv4_server_only=YES
echo "/usr/local/jails -alldirs -network 10.0.2.0 -mask 255.255.255.0" \
    > /etc/exports
service nfsd start

# Done — shut the VM down cleanly
poweroff
```

These settings persist in the qcow2 image. You perform this once. After the
VM powers off, the window closes and you are back at your shell.

> The book's Chapter 20 describes this console setup but starts the VM with
> `machine.sh`, which is headless. The `firstboot` command (and the
> `JFERRY_DISPLAY` variable it uses) provide the display you need for that
> one step. Everything after first boot is headless, over SSH, exactly as the
> chapter shows.

## Everyday use

```
./jferry start ~/projects   # Boot VM (headless), mount jail data from jferry.conf
./jferry pull cargo-bay-1   # Pull a jail from your production server
# ... edit files under ~/projects/jferry/, run them inside the jail ...
./jferry push cargo-bay-1   # Push your changes back to the server
./jferry stop               # Unmount shares, shut the VM down
./jferry status             # Show VM and share state
```

`jferry.conf` lives in your project directory and lists which jail paths to
mount, one per line: `jail-name  path-inside-jail  local-folder`. Lines
starting with `#` are ignored. No config file means no mounts.

## Configuration

The defaults at the top of `worker/machine.sh` and `worker/transport.sh` can
be overridden by environment variable before launch:

| Variable | Default | Meaning |
|----------|---------|---------|
| `JFERRY_RAM` | `2G` | VM memory |
| `JFERRY_CPUS` | `2` | VM virtual CPUs |
| `JFERRY_SSH_PORT` | `2223` | Host port forwarded to the VM's SSH |
| `JFERRY_NFS_PORT` | `12049` | Host port forwarded to the VM's NFS |
| `JFERRY_DISPLAY` | `none` | QEMU display; `none` is headless, e.g. `gtk`/`cocoa` for a window |

All commands were written against FreeBSD 15.0-RELEASE.
