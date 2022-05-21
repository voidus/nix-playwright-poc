{ pkgs ? import <nixpkgs> { }, rev }:

let
  inherit (pkgs) fetchzip;
  inherit (pkgs.stdenv) mkDerivation;

  inherit (pkgs.stdenv.hostPlatform) system;
  selectSystem = attrs:
    attrs.${system} or (throw "Unsupported system: ${system}");

  suffix = selectSystem {
    # Not sure how other system compatibility is, needs trial & error
    x86_64-linux = "ubuntu-20.04";
    # aarch64-linux = "ubuntu-20.04-arm64";
    # x86_64-darwin = "mac";
    # aarch64-darwin = "mac-arm64";
  };
  sha256 = {
    "1323" = selectSystem {
      x86_64-linux = "sha256-N9qGlC+d3M+vEGQYREWeOjmyvOccoJXhR4mM+VZ8NjI=";
    };
  }.${rev};

  upstream_firefox = fetchzip {
    url =
      "https://playwright.azureedge.net/builds/firefox/${rev}/firefox-${suffix}.zip";
    inherit sha256;
    stripRoot = true;
  };
in mkDerivation {
  name = "firefox-playwright";
  version = rev;
  src = upstream_firefox;

  nativeBuildInputs = [ pkgs.patchelf ];

  installPhase = ''
    mkdir $out

    cp -r $src/* $out/

    # patchelf the binary
    wrapper="${pkgs.firefox-bin}/bin/firefox"
    binary="$(readlink -f $(<"$wrapper" grep '^exec ' | grep -o -P '/nix/store/[^"]+' | head -n 1))"

    interpreter="$(patchelf --print-interpreter "$binary")"
    rpath="$(patchelf --print-rpath "$binary")"

    find $out -executable -type f | while read i; do
      chmod u+w "$i"
      [[ $i == *.so ]] || patchelf --set-interpreter "$interpreter" "$i"
      patchelf --set-rpath "$rpath" "$i"
      chmod u-w "$i"
    done


    # create the wrapper script
    rm $out/firefox
    <"$wrapper" grep -vE '^exec ' > $out/firefox
    echo "exec \"$out/firefox-bin\" \"\$@\"" >> $out/firefox
    chmod a+x $out/firefox
  '';
}
