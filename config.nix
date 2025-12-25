{ pkgs, lib, config, ... }: let
  inherit (pkgs) symlinkJoin runCommand;
  inherit (lib) types;
  inherit (lib.meta) getExe;
  inherit (lib.lists) findFirstIndex;
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkIf mkBefore;
  inherit (lib.strings) escapeShellArg;
  inherit (lib.attrsets) attrNames;

  cfg = config.boot.loader.grub.defaultSpecialisation;
in {
  imports = [ ./options.nix ];

  options.specialisation = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      config.configuration.environment.systemPackages = mkBefore [
        (pkgs.writeShellScriptBin "nixos-rebuild" ''
          for a in "$@"; do
            if [[ "$a" == "switch" ]] || [[ "$a" == "test" ]]; then
              exec ${getExe pkgs.nixos-rebuild} "$@" --specialisation ${escapeShellArg name}
            fi
          done

          exec ${getExe pkgs.nixos-rebuild} "$@"
        '')
        (runCommand "base-nixos-rebuild" {} ''
          mkdir -p $out/bin
          ln -s ${getExe pkgs.nixos-rebuild} $out/bin/base-nixos-rebuild
        '')
      ];
    }));
  };

  config = {
    boot.loader.grub = mkIf (cfg.name != null) {
      default = cfg.menuOffset + 1 + findFirstIndex (x: x == cfg.name) 0 (attrNames config.specialisation);
    };
  };
}
