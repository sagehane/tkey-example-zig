# generated by zon2nix (https://github.com/nix-community/zon2nix)

{ linkFarm, fetchzip }:

linkFarm "zig-packages" [
  {
    name = "12207afe41f161216c3de91c199ed859a8f8ba7faccb511dd60240f0af87175d8de2";
    path = fetchzip {
      url = "https://github.com/tillitis/tkey-libs/archive/refs/tags/v0.1.1.tar.gz";
      hash = "sha256-K+4Td7crh0gB/ZkizKZ3qFjcP3bsEmM9/3z5xgY1IIw=";
    };
  }
]