self: super:
let
  emptyDotCabal = self.runCommand "empty-dot-cabal" {
      nativeBuildInputs = [ self.cabal-install ];
    } ''
      mkdir -p $out/.cabal
      cat <<EOF > $out/.cabal/config
      EOF
    '';
  callCabalSdist = name: src: self.runCommand "${name}-sdist.tar.gz" {
      nativeBuildInputs = [ self.cabal-install ];
    } ''
      tmp=$(mktemp -d)
      cp -r ${src}/* $tmp
      cd $tmp
      tmp2=$(mktemp -d)
      HOME=${emptyDotCabal} cabal new-sdist -o $tmp2
      cp $tmp2/*.tar.gz $out
    '';
  callCabal2Nix = src: self.stdenv.mkDerivation {
    name = "package-nix";
    inherit src;
    nativeBuildInputs = [ self.haskell-nix.nix-tools ];
    phases = [ "unpackPhase" "buildPhase" ];
    buildPhase = ''
      cabal-to-nix *.cabal > $out
    '';
  };
  importCabal = name: src: builtins.trace (name + " " + toString src) (
    let sdist = callCabalSdist name src;
    in {...}@args:
         let oldPkg = import (callCabal2Nix sdist) args;
         in (oldPkg // { src = sdist; });
  # importCabal = name: src: import (callCabal2Nix (
  #   callCabalSdist name src));
in {
  # note: we want the ghc-boot-packages from
  # the *buildPackages*, as we want them from the
  # compiler we use to build this.
  ghc-boot-packages = builtins.mapAttrs (name: value:
    builtins.mapAttrs (pkgName: dir: importCabal "${name}-${pkgName}" "${value.passthru.configured-src}/${dir}") {
      ghc          = "compiler";
      ghci         = "libraries/ghci";
      ghc-boot     = "libraries/ghc-boot";
      libiserv     = "libraries/libiserv";
      iserv        = "utils/iserv";
      remote-iserv = "utils/remote-iserv";
      iserv-proxy  = "utils/iserv-proxy";
    }
  ) self.buildPackages.haskell.compiler;
}