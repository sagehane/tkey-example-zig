# SPDX-FileCopyrightText: 2024 Sage Hane <sage@sagehane.com>
#
# SPDX-License-Identifier: CC0-1.0

# Heavily based on https://github.com/mitchellh/zig-overlay/blob/f29dc15782be8458374ca7b303ca1c156da37a67/templates/init/flake.nix

{
  description = "Minimal Zig example for the TKey";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    let
      overlays = [
        (final: prev: {
          zigpkgs = inputs.zig.packages.${prev.system};
        })
      ];

      systems = builtins.attrNames inputs.zig.packages;
    in
    flake-utils.lib.eachSystem systems (
      system:
      let pkgs = import nixpkgs { inherit overlays system; }; in
      {
        packages.default = with pkgs; stdenv.mkDerivation {
          name = "tkey-example-zig";
          version = "0.2.0-dev";
          src = self;

          nativeBuildInputs = [ zigpkgs."0.12.0" ];

          installPhase = ''
            export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
            mkdir -p $ZIG_GLOBAL_CACHE_DIR
            ln -s ${callPackage ./deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
            zig build install -Drelease --prefix $out
          '';
        };
      }
    );
}
