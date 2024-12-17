{
  description = "Installs quartz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    quartz-src = {
      url = "github:jackyzha0/quartz";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    quartz-src,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    packages.${system}.default = pkgs.buildNpmPackage {
      name = "quartz";
      src = quartz-src;
      npmDepsHash = "sha256-q2MSzEbO8TKivJ7GR4RkNM2QTuyefFG3i4CS0LZ1cwY=";
      dontNpmBuild = true;
      installPhase = ''
        runHook preInstall
        npm install --production
        ln -s $out/lib/node_modules/quartz/bin/* $out/bin/
        ls - $out
        runHook postInstall
      '';
    };
    devShell.x86_64-linux = pkgs.mkShell {
      inputsFrom = [pkgs.nodejs self.packages.${system}.default];
      shellHook = ''
        echo  "quartz is ready"
      '';
    };
  };
}
