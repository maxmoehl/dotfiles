{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.buildEnv {
          name = "default";
          paths = with pkgs; [
	    bat
	    borgbackup
	    btop
	    cloudfoundry-cli
	    curl
	    delta
	    git
	    glow
	    gnused
	    go
	    jq
	    kubectl
	    kustomize
	    neovim
	    openssl
	    protobuf
	    scc
	    sqlite
	    step-cli
	    tcpdump
	    tmux
	    unixtools.watch
	    vault
	    yq-go
          ];
        };
      }
    );
}

