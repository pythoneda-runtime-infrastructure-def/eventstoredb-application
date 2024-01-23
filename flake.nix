# flake.nix
#
# This file packages pythoneda-runtime/boot-application as a Nix flake.
#
# Copyright (C) 2024-today rydnr's pythoneda-runtime-def/boot-application
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description = "Application layer for pythoneda-runtime/boot";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixos.url = "github:NixOS/nixpkgs/23.11";
    pythoneda-runtime-boot = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows = "pythoneda-shared-domain";
      url = "github:pythoneda-runtime-def/boot/0.0.4";
    };
    pythoneda-runtime-boot-infrastructure = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-runtime-boot.follows = "pythoneda-runtime-boot";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows = "pythoneda-shared-domain";
      url = "github:pythoneda-runtime-def/boot-infrastructure/0.0.3";
    };
    pythoneda-shared-application = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows = "pythoneda-shared-domain";
      url = "github:pythoneda-shared-def/application/0.0.46";
    };
    pythoneda-shared-banner = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      url = "github:pythoneda-shared-def/banner/0.0.47";
    };
    pythoneda-shared-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      url = "github:pythoneda-shared-def/domain/0.0.27";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        org = "pythoneda-runtime";
        repo = "boot-application";
        version = "0.0.1";
        sha256 = "0s2wawzyz1annicms4s540fqsm0666i1r35l5bw5sl38dxj8bh77";
        pname = "${org}-${repo}";
        pythonpackage = builtins.replaceStrings [ "-" ] [ "." ] pname;
        package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
        entrypoint = "boot_app";
        description = "Application layer for pythoneda-runtime/boot";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = with pkgs.lib.maintainers;
          [ "rydnr <github@acm-sl.org>" ];
        archRole = "B";
        space = "R";
        layer = "A";
        nixosVersion = builtins.readFile "${nixos}/.version";
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixos-${nixosVersion}";
        shared = import "${pythoneda-shared-banner}/nix/shared.nix";
        pkgs = import nixos { inherit system; };
        pythoneda-runtime-boot-application-for = { python
          , pythoneda-runtime-boot, pythoneda-runtime-boot-infrastructure
          , pythoneda-shared-application, pythoneda-shared-banner
          , pythoneda-shared-domain }:
          let
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
            banner_file = "${package}/boot_banner.py";
            banner_class = "BootBanner";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTemplateFile = ./pyprojecttoml.template;
            pyprojectTemplate = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage package pname pythonMajorMinorVersion
                pythonpackage version;
              pythonedaRuntimeBoot = pythoneda-runtime-boot.version;
              pythonedaRuntimeBootInfrastructure =
                pythoneda-runtime-boot-infrastructure.version;
              pythonedaSharedApplication = pythoneda-shared-application.version;
              pythonedaSharedBanner = pythoneda-shared-banner.version;
              pythonedaSharedDomain = pythoneda-shared-domain.version;
              src = pyprojectTemplateFile;
            };
            bannerTemplateFile =
              "${pythoneda-shared-banner}/templates/banner.py.template";
            bannerTemplate = pkgs.substituteAll {
              project_name = pname;
              file_path = banner_file;
              inherit banner_class org repo;
              tag = version;
              pescio_space = space;
              arch_role = archRole;
              hexagonal_layer = layer;
              python_version = pythonMajorMinorVersion;
              nixpkgs_release = nixpkgsRelease;
              src = bannerTemplateFile;
            };

            entrypointTemplateFile =
              "${pythoneda-shared-banner}/templates/entrypoint.sh.template";
            entrypointTemplate = pkgs.substituteAll {
              arch_role = archRole;
              hexagonal_layer = layer;
              nixpkgs_release = nixpkgsRelease;
              inherit homepage maintainers org python repo version;
              pescio_space = space;
              python_version = pythonMajorMinorVersion;
              pythoneda_shared_banner = pythoneda-shared-banner;
              pythoneda_shared_domain = pythoneda-shared-domain;
              src = entrypointTemplateFile;
            };
            src = pkgs.fetchFromGitHub {
              owner = org;
              rev = version;
              inherit repo sha256;
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-runtime-boot
              pythoneda-runtime-boot-infrastructure
              pythoneda-shared-application
              pythoneda-shared-banner
              pythoneda-shared-domain
            ];

            # pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              chmod -R +w $sourceRoot
              cp ${pyprojectTemplate} $sourceRoot/pyproject.toml
              cp ${bannerTemplate} $sourceRoot/${banner_file}
              cp ${entrypointTemplate} $sourceRoot/entrypoint.sh
            '';

            postPatch = ''
              substituteInPlace /build/$sourceRoot/entrypoint.sh \
                --replace "@SOURCE@" "$out/bin/${entrypoint}.sh" \
                --replace "@PYTHONPATH@" "$PYTHONPATH" \
                --replace "@CUSTOM_CONTENT@" "" \
                --replace "@ENTRYPOINT@" "$out/lib/python${pythonMajorMinorVersion}/site-packages/${package}/${entrypoint}.py"
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist $out/bin
              cp dist/${wheelName} $out/dist
              cp /build/$sourceRoot/entrypoint.sh $out/bin/${entrypoint}.sh
              chmod +x $out/bin/${entrypoint}.sh
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        apps = rec {
          default = pythoneda-runtime-boot-application-default;
          pythoneda-runtime-boot-application-default =
            pythoneda-runtime-boot-application-python311;
          pythoneda-runtime-boot-application-python38 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-runtime-boot-application-python38;
            inherit entrypoint;
          };
          pythoneda-runtime-boot-application-python39 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-runtime-boot-application-python39;
            inherit entrypoint;
          };
          pythoneda-runtime-boot-application-python310 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-runtime-boot-application-python310;
            inherit entrypoint;
          };
          pythoneda-runtime-boot-application-python311 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-runtime-boot-application-python311;
            inherit entrypoint;
          };
        };
        defaultApp = apps.default;
        defaultPackage = packages.default;
        devShells = rec {
          default = pythoneda-runtime-boot-application-default;
          pythoneda-runtime-boot-application-default =
            pythoneda-runtime-boot-application-python311;
          pythoneda-runtime-boot-application-python38 = shared.devShell-for {
            banner = "${
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.pythoneda-runtime-boot-application-python38;
            python = pkgs.python38;
            pythoneda-shared-domain =
              pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python38;
            pythoneda-shared-banner =
              pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38;
            inherit archRole layer org pkgs repo space;
          };
          pythoneda-runtime-boot-application-python39 = shared.devShell-for {
            banner = "${
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python39
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.pythoneda-runtime-boot-application-python39;
            python = pkgs.python39;
            pythoneda-shared-domain =
              pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python39;
            pythoneda-shared-banner =
              pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python39;
            inherit archRole layer org pkgs repo space;
          };
          pythoneda-runtime-boot-application-python310 = shared.devShell-for {
            banner = "${
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python310
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.pythoneda-runtime-boot-application-python310;
            python = pkgs.python310;
            pythoneda-shared-domain =
              pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python310;
            pythoneda-shared-banner =
              pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python310;
            inherit archRole layer org pkgs repo space;
          };
          pythoneda-runtime-boot-application-python311 = shared.devShell-for {
            banner = "${
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python311
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.pythoneda-runtime-boot-application-python311;
            python = pkgs.python311;
            pythoneda-shared-domain =
              pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python311;
            pythoneda-shared-banner =
              pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python311;
            inherit archRole layer org pkgs repo space;
          };
        };
        packages = rec {
          default = pythoneda-runtime-boot-application-default;
          pythoneda-runtime-boot-application-default =
            pythoneda-runtime-boot-application-python311;
          pythoneda-runtime-boot-application-python38 =
            pythoneda-runtime-boot-application-for {
              python = pkgs.python38;
              pythoneda-runtime-boot =
                pythoneda-runtime-boot.packages.${system}.pythoneda-runtime-boot-python38;
              pythoneda-runtime-boot-infrastructure =
                pythoneda-runtime-boot-infrastructure.packages.${system}.pythoneda-runtime-boot-infrastructure-python38;
              pythoneda-shared-application =
                pythoneda-shared-application.packages.${system}.pythoneda-shared-application-python38;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python38;
            };
          pythoneda-runtime-boot-application-python39 =
            pythoneda-runtime-boot-application-for {
              python = pkgs.python39;
              pythoneda-runtime-boot =
                pythoneda-runtime-boot.packages.${system}.pythoneda-runtime-boot-python39;
              pythoneda-runtime-boot-infrastructure =
                pythoneda-runtime-boot-infrastructure.packages.${system}.pythoneda-runtime-boot-infrastructure-python39;
              pythoneda-shared-application =
                pythoneda-shared-application.packages.${system}.pythoneda-shared-application-python39;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python39;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python39;
            };
          pythoneda-runtime-boot-application-python310 =
            pythoneda-runtime-boot-application-for {
              python = pkgs.python310;
              pythoneda-runtime-boot =
                pythoneda-runtime-boot.packages.${system}.pythoneda-runtime-boot-python310;
              pythoneda-runtime-boot-infrastructure =
                pythoneda-runtime-boot-infrastructure.packages.${system}.pythoneda-runtime-boot-infrastructure-python310;
              pythoneda-shared-application =
                pythoneda-shared-application.packages.${system}.pythoneda-shared-application-python310;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python310;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python310;
            };
          pythoneda-runtime-boot-application-python311 =
            pythoneda-runtime-boot-application-for {
              python = pkgs.python311;
              pythoneda-runtime-boot =
                pythoneda-runtime-boot.packages.${system}.pythoneda-runtime-boot-python311;
              pythoneda-runtime-boot-infrastructure =
                pythoneda-runtime-boot-infrastructure.packages.${system}.pythoneda-runtime-boot-infrastructure-python311;
              pythoneda-shared-application =
                pythoneda-shared-application.packages.${system}.pythoneda-shared-application-python311;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python311;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python311;
            };
        };
      });
}
