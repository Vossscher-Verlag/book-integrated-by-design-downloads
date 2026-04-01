# Integrated by Design — Downloads

Companion repository for **Integrated by Design — Why the Best Systems Are the Ones You Don't Notice** by Vivian Voss.

Every script and configuration file from the book, ready to use.

## Contents

```
ch07-firewall/              pf.conf templates (basic + production)
ch16-from-zero-to-server/   rc.conf base configuration
ch17-your-first-jail/       jail.conf for a learning jail
ch18-web-stack/             Three-jail web stack (Caddy + nginx + PostgreSQL)
ch19-jails-in-production/   Multi-tenant jail templates, hardened pf rules
ch20-from-server-to-laptop/ jferry — local FreeBSD development with QEMU
```

## jferry

The `jferry` tool (Chapter 20) lets you run FreeBSD jails on your laptop using QEMU. It downloads a FreeBSD VM image, starts the VM, and mounts jail data via NFS so you can edit files locally.

```
jferry start /path/to/project   # Boot VM, mount jail data
jferry stop                     # Unmount, shut down VM
jferry pull cargo-bay-1         # Pull a jail from your server
jferry push cargo-bay-1         # Push changes back
jferry status                   # Show VM and share state
```

Requirements: QEMU (`brew install qemu` on macOS).

## Chapter reference

Each file includes a comment header referencing its chapter in the book. All commands were tested on FreeBSD 15.0-RELEASE.

## Naming conventions

The examples use Star Trek naming throughout, consistent with the book:

- Hostnames: `enterprise`, `defiant`, `runabout`
- Jails: `cargo-bay-1`, `shuttle-bay`, `astrometrics`
- Users: `picard` (admin), `worf` (security), `geordi` (infrastructure)

## Found an error?

Help make the book better. If you spot a typo, a factual error, an outdated command, or anything that could be improved, [open a correction](../../issues/new?template=correction.yml). Every confirmed correction is fixed in the next edition, and contributors are acknowledged by name in the book.

## License

BSD 2-Clause. See [LICENSE](LICENSE).
