{ pkgs ? import <nixpkgs> { }, playwright_version, data_sha256 }:

let
  inherit (builtins) fetchurl map fromJSON readFile listToAttrs;

  browser_revs = let
    file = fetchurl {
      url =
        "https://raw.githubusercontent.com/microsoft/playwright/v${playwright_version}/packages/playwright-core/browsers.json";
      sha256 = data_sha256;
    };
    raw_data = fromJSON (readFile file);
  in listToAttrs (map ({ name, revision, ... }: {
    inherit name;
    value = revision;
  }) raw_data.browsers);

  chromium-playwright = import ./chromium-playwright.nix {
    inherit pkgs;
    rev = browser_revs.chromium;
  };
  firefox-playwright = import ./firefox-playwright.nix {
    inherit pkgs;
    rev = browser_revs.firefox;
  };
in {
  chromium = "${chromium-playwright}/chrome";
  firefox = "${firefox-playwright}/firefox";
}

