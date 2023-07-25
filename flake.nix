{
  inputs = {
    ### Nixpkgs ###
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    ### Flake / Project Inputs ###
    flake-parts.url = "github:hercules-ci/flake-parts";

    flake-root.url = "github:srid/flake-root";

    mission-control.url = "github:Platonic-Systems/mission-control";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.flake-utils.inputs.systems.follows = "systems";
    };

    systems.url = "github:nix-systems/default";

    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    flake-root,
    mission-control,
    pre-commit-hooks,
    systems,
    treefmt,
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      withSystem,
      inputs,
      ...
    }: {
      systems = import systems;
      imports = [
        flake-root.flakeModule
        mission-control.flakeModule
        pre-commit-hooks.flakeModule
        treefmt.flakeModule
      ];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        lib,
        ...
      }: {
        packages = with lib.attrsets; let
          f = n: v: v.config.nixpkgs.system == system;
          nixos = mapAttrs (n: v: v.config.system.build.toplevel) (filterAttrs f self.nixosConfigurations);
          # darwin = mapAttrs (n: v: v.system) (filterAttrs f self.darwinConfigurations);
          darwin = {};

          compile-templates = let
            templates-dir = "${dirOf config.flake-root.projectRootFile}/cluster/templates";
          in
            pkgs.writeShellScriptBin "compile-templates" ''
              #!${pkgs.stdenv}/bin/bash
              ${pkgs.mustache-go}/bin/mustache ${templates-dir}/repos.data.yaml ${templates-dir}/repos.mustache > ${templates-dir}/repos.yaml
            '';
        in
          nixos
          // darwin
          // {
            inherit compile-templates;
          };

        devShells.default = pkgs.mkShell {
          inputsFrom = [
            config.mission-control.devShell
            config.pre-commit.devShell
            config.treefmt.build.devShell
          ];
          buildInputs = with pkgs; [
            fluxcd
            kubectl
            sops
            age
            terraform
            pulumi
            pulumiPackages.pulumi-language-nodejs
            nodejs
            aws-iam-authenticator
            awscli2

            self'.packages.compile-templates
          ];
        };

        mission-control.scripts = {
          fmt = {
            description = "Format the source tree";
            exec = config.treefmt.build.wrapper;
            category = "Dev Tools";
          };
        };

        pre-commit = {
          check.enable = true;

          settings.hooks.treefmt.enable = true;
          settings.settings.treefmt.package = config.treefmt.build.wrapper;

          settings.hooks.templates = {
            enable = true;
            name = "templates";
            entry = "${self'.packages.compile-templates}/bin/compile-templates";
            language = "system";
            pass_filenames = false;
          };
        };

        treefmt.config = {
          inherit (config.flake-root) projectRootFile;
          package = pkgs.treefmt;
          programs.alejandra.enable = true;
        };
        formatter = config.treefmt.build.wrapper;
      };

      flake = {
        nixosConfigurations.hbot = withSystem "x86_64-linux" (ctx @ {
          system,
          config,
          inputs',
          ...
        }:
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./configuration.nix
            ];
          });
      };
    });
}
