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
        ghc = pkgs.haskell.packages.ghc98.ghcWithPackages (ps: with ps; [ clock ]);
        agda = pkgs.agda.withPackages {
          inherit ghc;
          pkgs = ps: [ ps.standard-library ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = (with pkgs; [ marksman ghc agda ]);
          shellHook = ''
            ${ghc}/bin/ghc --version
            ${agda}/bin/agda --version
          '';
        };
      }
    );
}
