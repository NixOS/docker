This image contains an installation of the [Nix package manager](https://nixos.org/nix/).

Use this build to create your own customized images as follows:

    FROM nixos/nix

    RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
    RUN nix-channel --update

    RUN nix-build -A pythonFull '<nixpkgs>'
