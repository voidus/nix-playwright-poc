# confirmed working with rev 934e076a441e318897aa17540f6cf7caadc69028
{ pkgs ? import <nixpkgs> {} }:

let
  # Make sure to adjust data_sha256 when updating this or it will use stale data!
  playwright_version = "1.22.0";
  playwright-browsers = import ./nix/playwright-browsers.nix {
    inherit playwright_version;
    data_sha256 = "sha256:1jbq5xdklw2n8cqxjv912q124wmlqkwv6inlf6qw76x9ns16lv18";
  };
in
  pkgs.mkShell {
    packages = [
      pkgs.poetry
      pkgs.python
    ];

    "POC_PLAYWRIGHT_VERSION" = playwright_version;
    "POC_PLAYWRIGHT_CHROMIUM" = playwright-browsers.chromium;
    "POC_PLAYWRIGHT_FIREFOX" = playwright-browsers.firefox;
  }
