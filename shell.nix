{
  inputs,
  forEachSystem,
  checks,
  ...
}:

forEachSystem (
  system:
  let
    inherit (inputs) nixpkgs sops-nix;
    pkgs = nixpkgs.legacyPackages.${system};

    # construct the shell provided by pre-commit for running hooks
    pre-commit = pkgs.mkShell {
      inherit (checks.${system}.pre-commit-check) shellHook;
      buildInputs = checks.${system}.pre-commit-check.enabledPackages;
    };

    # construct a shell for importing sops keys (also provides the sops binary)
    sops = pkgs.mkShell {
      sopsPGPKeyDirs = [ "./keys" ];
      packages = [
        pkgs.sops
        sops-nix.packages.${system}.sops-import-keys-hook
      ];
    };

    # constructs a custom shell with commonly used utilities
    rad-dev = pkgs.mkShell {
      packages = with pkgs; [
        deadnix
        pre-commit
        treefmt
        statix
        nixfmt-rfc-style
      ];
    };
  in
  {
    default = pkgs.mkShell {
      inputsFrom = [
        pre-commit
        rad-dev
        sops
      ];
    };
  }
)
