{ pkgs
}:
with pkgs;
(
  let
    result = rec {
      bittensor_cli = python313Packages.buildPythonPackage
        {
          pname = "bittensor_cli";
          version = "9.18.1";
          src = fetchPypi {
            pname = "bittensor_cli";
            version = "9.18.1";
            hash = "sha256-9j/bQ0WgEAUlVf490jji3oy8ENu11pT/x+mDWVpel/o=";
          };
          pyproject = true;
          build-system = [ python313.pkgs.setuptools ];
          dependencies = [
            scalecodec
            async_substrate_interface
            bittensor_drand
            bittensor_wallet

            python313Packages.aiohttp
            python313Packages.flit-core
            python313Packages.backoff
            python313Packages.gitpython
            python313Packages.netaddr
            python313Packages.numpy
            python313Packages.jinja2
            python313Packages.pycryptodome
            python313Packages.pyyaml
            python313Packages.rich
            python313Packages.typer
            python313Packages.plotille
            python313Packages.plotly
          ];
          nativeBuildInputs = with rustPlatform; [ maturinBuildHook ];
          doCheck = false;
        };

      bittensor_drand = python313Packages.buildPythonPackage
        rec {
          pname = "bittensor_drand";
          version = "1.1.0";
          src = fetchPypi {
            pname = "bittensor_drand";
            version = "1.1.0";
            hash = "sha256-MfUgrku1DhEH0Qtj0vcdZk9CfwbhUfk4weBlrSHxCmc=";
          };
          pyproject = true;
          build-system = [ python313Packages.setuptools python313Packages.wheel ];

          rustTleSrc = fetchFromGitHub {
            owner = "ideal-lab5";
            repo = "timelock";
            rev = "5416406cfd32799e31e1795393d4916894de4468";
            hash = "sha256-QsPCQhNZKYCAogQriQX6pBYQUDAIUsEdRX/63dAqTzg=";
          };

          cargoDeps = rustPlatform.fetchCargoVendor {
            inherit pname version rustTleSrc;
            hash = "sha256-QsPCQhNZKYCAogQriQX6pBYQUDAIUsEdRX/63dAqTzg=";
          };

          nativeBuildInputs = with rustPlatform; [ cargoSetupHook maturinBuildHook ];
          dependencies = [
          ];
          doCheck = false;
        };

      bittensor_wallet = python313Packages.buildPythonPackage rec {
        pname = "bittensor_wallet";
        version = "4.0.0";
        src = fetchPypi {
          pname = "bittensor_wallet";
          version = "4.0.0";
          hash = "sha256-n5kOrHSwiJf5/JqK9GDVZrXPtuVC8DE+SJaoCUSb60c=";
        };
        pyproject = true;
        build-system = [ python313Packages.setuptools python313Packages.wheel ];

        rustTleSrc = fetchFromGitHub {
          owner = "ideal-lab5";
          repo = "timelock";
          rev = "5416406cfd32799e31e1795393d4916894de4468";
          hash = "sha256-QsPCQhNZKYCAogQriQX6pBYQUDAIUsEdRX/63dAqTzg=";
        };

        cargoDeps = rustPlatform.fetchCargoVendor {
          inherit pname version rustTleSrc;
          hash = "sha256-QsPCQhNZKYCAogQriQX6pBYQUDAIUsEdRX/63dAqTzg=";
        };

        nativeBuildInputs = with rustPlatform; [ cargoSetupHook maturinBuildHook ];

        dependencies = [
        ];
        doCheck = false;
      };

      async_substrate_interface = python313Packages.buildPythonPackage {
        pname = "async_substrate_interface";
        version = "1.6.1";
        src = fetchPypi {
          pname = "async_substrate_interface";
          version = "1.6.1";
          hash = "sha256-q/J7mZhCMqgKelKaQUmXsio/cGXaiEldBxNppHtna4Q=";
        };
        pyproject = true;
        build-system = [ python313Packages.setuptools python313Packages.wheel ];
        dontCheckBuildDeps = true;
        dontCheckRuntimeDeps = true;
        nativeBuildInputs = [
          python313Packages.pythonRelaxDepsHook
          python313Packages.setuptools
          python313Packages.wheel
        ];
        pythonRelaxDeps = [
          "setuptools"
          "wheel"
        ];
        dependencies = [
          python313Packages.setuptools
          python313Packages.wheel

          python313Packages.websockets
          scalecodec
        ];
        doCheck = false;
      };

      scalecodec = python313Packages.buildPythonPackage {
        pname = "scalecodec";
        version = "2.0.0a2";
        src = fetchPypi {
          pname = "scalecodec";
          version = "2.0.0a2";
          hash = "sha256-QgdgrS8hwH7V/UAIZAs2PQUlB5Ty4Y/WTzT57w7KKMU=";
        };
        pyproject = true;
        build-system = [ python313Packages.setuptools ];
        dependencies = [
          python313Packages.requests
          python313Packages.more-itertools
          python313Packages.base58
        ];
        doCheck = false;
      };
    };
  in
  python313.withPackages
    (
      ps: with ps;
      [
        result.bittensor_cli
      ]
    )
).env
