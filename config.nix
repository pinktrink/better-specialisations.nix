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
          all=()
          pos=""
          while [[ "$#" -gt 0 ]]; do
            if [[ "$1" != -* ]] && [[ -z "$pos" ]]; then
              pos="$1"
              shift
            elif [[ "$1" =~ ^--(max-jobs|cores|log-format|builders|include|update-input|file|attr|profile-name|specialisation|build-host|target-host|image-variant) ]] || [[ "$1" = "--flake" ]] && [[ "$2" != -* ]]; then
              all+=("$1" "$2")
              shift
              shift
            elif [[ "$1" =~ ^--(option|override-input) ]]; then
              all+=("$1" "$2" "$3")
              shift
              shift
              shift
            else
              all+=("$1")
              shift
            fi
          done

          if [[ "$pos" = "switch" ]]; then
            ${getExe pkgs.nixos-rebuild} "''${all[@]}" boot
            exec /nix/var/nix/profiles/system/specialisation/${escapeShellArg name}/bin/switch-to-configuration test
          elif [[ "$pos" = "test" ]]; then
            exec ${getExe pkgs.nixos-rebuild} --specialisation ${escapeShellArg name} "''${all[@]}" "$pos"
          fi
          exec ${getExe pkgs.nixos-rebuild} "''${all[@]}" "$pos"
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
