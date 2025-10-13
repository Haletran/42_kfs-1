{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          shell = pkgs.zsh;

          buildInputs = [
            pkgs.zig
            pkgs.zsh
            pkgs.tigervnc
            pkgs.mtools
          ];

          shellHook = ''
            if [ ! -d "tools" ]; then
              wget https://github.com/lordmilko/i686-elf-tools/releases/download/7.1.0/i686-elf-tools-linux.zip
              unzip i686-elf-tools-linux.zip -d tools
              rm i686-elf-tools-linux.zip
            fi 
            #exec zsh
          '';
        };
      });
}
