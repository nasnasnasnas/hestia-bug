{
  description = "Minimal Hestia + Blacksmith cache repro";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      forAllSystems = f:
        nixpkgs.lib.genAttrs systems
          (system: f (import nixpkgs { inherit system; }));
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.runCommand "hestia-cache-smoke-${pkgs.stdenv.hostPlatform.system}"
          {
            nativeBuildInputs = [ pkgs.python3 ];
          }
          ''
            echo "BUILDING-HestiaCacheSmokeTest system=${pkgs.stdenv.hostPlatform.system}" >&2

            mkdir -p "$out"

            python3 - <<'PY'
import os
import random

out = os.environ["out"]
rng = random.Random(123456789)

with open(os.path.join(out, "payload.bin"), "wb") as f:
    for _ in range(64):
        f.write(rng.randbytes(1024 * 1024))

with open(os.path.join(out, "result.txt"), "w") as f:
    f.write("built\n")
PY
          '';
      });
    };
}
