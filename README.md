This image contains an installation of the [Nix package manager](https://nixos.org/nix/).

Use this build to create your own customized images as follows:

    FROM nixos/nix

    RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
    RUN nix-channel --update

    RUN nix-build -A pythonFull '<nixpkgs>'

### Limitations

By default [sandboxing](https://nixos.org/manual/nix/stable/command-ref/conf-file.html?highlight=sandbox#description) is turned off 
inside the container, even though it is enabled in new installations of nix. This
can lead to differences between derivations built inside a docker container versus those built
without any containerization, especially if a derivation relies on sandboxing to block
sideloading of dependencies. 

To enable sandboxing the container has to be started with the 
[`--privileged`](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities)
flag and `sandbox = true` set in `/etc/nix/nix.conf`.
