{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        formatter = pkgs.nixfmt;
        packages.default = pkgs.buildEnv {
          name = "default";
          paths = with pkgs; [
            alacritty
            bat
            borgbackup
            btop
            cloudfoundry-cli
            curl
            delta
            direnv
            git
            glow
            gnupg
            gnused
            go
            graphviz
            jq
            lua
            neovim
            opensc
            openssh
            openssl
            pandoc
            pass
            pinentry_mac
            protobuf
            rustc
            cargo
            scc
            sqlite
            sslscan
            tcpdump
            tmux
            unixtools.watch
            vault
            yq-go
            yubikey-manager
          ];
        };
      });
}

