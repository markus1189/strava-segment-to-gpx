{
  description = "A very basic flake";

  inputs = { flake-utils.url = "github:numtide/flake-utils"; };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        py3pkgs = pkgs.python3.pkgs;
        segmentToGpx = pkgs.writeShellApplication {
          name = "segment-to-gpx.sh";
          runtimeInputs = with pkgs; [ jq curl cacert pup pandoc yq coreutils gpx_from_polyline];
          text = pkgs.lib.readFile ./segment-to-gpx.sh;
        };
        gpx_from_polyline = (pkgs.writers.writePython3Bin "gpx_from_polyline" {
          libraries = with py3pkgs; [ gpxpy polyline ];
        } (pkgs.lib.readFile ./gpx_from_polyline.py)).overrideAttrs
          (old: { check = ":"; });
      in rec {
        apps.segmentToGpx = {
          type = "app";
          program = "${segmentToGpx}/bin/segment-to-gpx.sh";
        };
        apps.gpx_from_polyline = {
          type = "app";
          program = "${gpx_from_polyline}/bin/gpx_from_polyline";
        };
        defaultApp = apps.segmentToGpx;
      });
}
