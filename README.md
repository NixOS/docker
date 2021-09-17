This image contains an installation of the [Nix package manager](https://nixos.org/nix/).

The image must be built with [buildkit].
Use this build to create your own customized images as follows:

[buildkit]: https://docs.docker.com/go/buildkit/

```Dockerfile
FROM nixos/nix

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
RUN nix-channel --update

RUN nix-build -A pythonFull '<nixpkgs>'
```

### Limitations

By default both [sandboxing] and `filter-syscalls` is turned off inside the container, even though both are enabled in new installations of nix.
`sandbox = false` can lead to differences between derivations built inside a docker container versus those built without any containerization.
Differences are especially likely if a derivation relies on sandboxing to block sideloading of dependencies.

[sandboxing]: https://nixos.org/manual/nix/stable/#conf-sandbox

To enable sandboxing the container has to be started with the  [`--privileged`] flag and `sandbox = true` set in `/etc/nix/nix.conf`.
To enable syscall filtering the container has to be started with the  [`--privileged`] flag and `filter-syscalls = true` set in `/etc/nix/nix.conf`.

[`--privileged`]: https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities
