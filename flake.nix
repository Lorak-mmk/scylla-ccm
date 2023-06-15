{
  description = "A script/library to create, launch and remove an Scylla / Apache Cassandra cluster on
localhost.";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      make_ccm_package = pkgs: pkgs.python3Packages.buildPythonApplication {
        pname = "scylla_ccm";
        version = "0.1";

        src = ./. ;

        checkInputs = with pkgs.python3Packages; [ pytestCheckHook ];
        propagatedBuildInputs =  with pkgs.python3Packages; [ pyyaml psutil six requests packaging boto3 tqdm setuptools ];
        doCheck = false;

        disabledTestPaths = [ "old_tests/*.py" ];

        # Make `nix run` aware that the binary is called `ccm`.
        meta.mainProgram = "ccm";
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let 
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          scylla_ccm = make_ccm_package pkgs;
          default = scylla_ccm;
        };
      }
    ) // rec {
      overlays.default = final: prev: {
        scylla_ccm = make_ccm_package final;
      };
    };
}
