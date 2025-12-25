{ lib, ... }: let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in {
  options.boot.loader.grub.defaultSpecialisation = {
    name = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The name of the default specialisation selected in the bootloader menu.
      '';
    };
    menuOffset = mkOption {
      type = types.int;
      default = 0;
      description = ''
        The offset to add to the number selection in the bootloader menu. This is useful if you have additional entries in the boot loader menu alongside `boot.loader.grub.extraEntriesBeforeNixos`.
      '';
    };
  };
}
