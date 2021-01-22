{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
}:

# Convert the JSON matrix into an attrset of derivations
# You can build indvidual images like `nix-build matrix.nix -A nixos-20.09-x86_64-linux`
let
  matrix = lib.importJSON ./matrix.json;
in
lib.listToAttrs (lib.foldl'
  (acc: system: acc ++ (lib.mapAttrsToList (name: channel: (
    let
      tag = name + "-" + system;
    in
    {
      name = tag;
      value = import ./default.nix {
        pkgs = import (builtins.fetchTarball "${channel.url}/nixexprs.tar.xz") { };
        name = "docker.io/nixos/nix";
        inherit tag;
        crossSystem = system;
        channelName = channel.name;
        channelURL = channel.url;
      };
    }
  ))) matrix.channels) [ ]
  matrix.systems)
