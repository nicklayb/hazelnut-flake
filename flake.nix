{
  description = "Hazelnut file organizer for Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hazelnut-src = {
      url = "github:ricardodantas/hazelnut";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      hazelnut-src,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          hazelnut = pkgs.rustPlatform.buildRustPackage {
            pname = "hazelnut";
            version = "0.3.0";

            src = hazelnut-src;

            cargoLock = {
              lockFile = "${hazelnut-src}/Cargo.lock";
            };

            meta = {
              description = "Terminal-based automated file organizer";
              homepage = "https://github.com/ricardodantas/hazelnut";
              license = nixpkgs.lib.licenses.gpl3Only;
              mainProgram = "hazelnut";
            };
          };

          default = self.packages.${system}.hazelnut;
        }
      );

      homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          _module.args.hazelnutPackage = self.packages.${pkgs.system}.hazelnut;

          imports = [
            ./home-manager.nix
          ];
        };
    };
}
