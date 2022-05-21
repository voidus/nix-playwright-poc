{ pkgs ? import <nixpkgs> { }, rev }:

let
  inherit (pkgs) fetchzip;
  inherit (pkgs.stdenv) mkDerivation;

  inherit (pkgs.stdenv.hostPlatform) system;
  selectSystem = attrs:
    attrs.${system} or (throw "Unsupported system: ${system}");

  suffix = selectSystem {
    # Not sure how other system compatibility is, needs trial & error
    x86_64-linux = "linux";
    aarch64-linux = "linux-arm64";
    # x86_64-darwin = "mac";
    # aarch64-darwin = "mac-arm64";
  };
  sha256 = {
    # Fill in on demand
    "1005" = selectSystem {
      x86_64-linux = "sha256-HfsvjiFKjlYQJqug2hj0z3CVp1o0TMyIw4Kybr82kbo=";
    };
  }.${rev};

  upstream_chromium = fetchzip {
    url =
      "https://playwright.azureedge.net/builds/chromium/${rev}/chromium-${suffix}.zip";
    inherit sha256;
    stripRoot = true;
  };
in mkDerivation {
  name = "chromium-playwright";
  version = rev;
  src = upstream_chromium;

  nativeBuildInputs = [ pkgs.patchelf ];

  installPhase = ''
    mkdir $out

    cp -r $src/* $out/

    # patchelf the binary
    wrapper="${pkgs.google-chrome-dev}/bin/google-chrome-unstable"
    wrapper_2="$(cat "$wrapper" | grep '^exec ' | grep -o -P '/nix/store/[^"]+' | head -n 1)"
    binary="$(dirname "$wrapper_2")/chrome"
    interpreter="$(patchelf --print-interpreter "$binary")"
    rpath="$(patchelf --print-rpath "$binary")"

    chmod u+w $out/chrome
    stat $out/chrome
    patchelf --set-interpreter "$interpreter" $out/chrome
    patchelf --set-rpath "$rpath" $out/chrome
    chmod u-w $out/chrome

    # create the wrapper script
    mv $out/chrome $out/chrome.bin
    cat "$wrapper" | grep -vE '^exec ' > $out/chrome
    echo "exec \"$out/chrome.bin\" \"\$@\"" >> $out/chrome
    chmod a+x $out/chrome
  '';
}
