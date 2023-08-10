{
  description = "my personal note taking system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        agda-stdlib = ps: (ps.standard-library.overrideAttrs (_: {
          version = "2.0";
          src = pkgs.fetchFromGitHub {
            repo = "agda-stdlib";
            owner = "agda";
            rev = "177dc9e983606b653a3c6af2ae2162bbc87882ad";
            sha256 = "sha256-ovnhL5otoaACpqHZnk/ucivwtEfBQtGRu4/xw4+Ws+c=";
          };
        }));
        ghc = pkgs.haskell.packages.ghc94.ghcWithPackages (ps: with ps; [ clock ]);
        agda = pkgs.agda.withPackages {
          inherit ghc;
          pkgs = ps: [ (agda-stdlib ps) ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = (with pkgs; [ marksman agda ghc ]) ++
            (with pkgs.haskellPackages; [ text containers ]);
          shellHook = ''
            echo "---------- japiirainen's note taking environment ------------"
            ${agda}/bin/agda --version
            ${ghc}/bin/ghc --version
            echo "-------------------------------------------------------------"
          '';
        };
      }
    );
}
