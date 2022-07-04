{
  description = "A very basic flake";

  inputs = { flake-utils.url = "github:numtide/flake-utils"; };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        segmentToGpx = pkgs.writeShellApplication {
          name = "segment-to-gpx.sh";
          runtimeInputs = with pkgs; [ jq curl cacert pup pandoc yq coreutils ];
          text = pkgs.lib.readFile ./segment-to-gpx.sh;
        };
      in rec {
        apps = { inherit segmentToGpx; };
        defaultApp = apps.segmentToGpx;
      });
}
