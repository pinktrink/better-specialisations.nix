More ergonomic specialisations for NixOS.

**BEWARE: Currently this only works with the GRUB bootloader.**

By default, in NixOS, specialisations cannot be pre-selected in the bootloader. For the way that NixOS specialisations work by default, this is expected, due to the fact that your default nixos configuration typically includes configuration for GUI environments, etc, and specialisations inherit those.

Consider the following:

* Specialisations require a ton of `mkForce` in order to override options defined in your default configuraion.
* When in a specialisation, `nixos-rebuild` requires you to pass the `--specialisation` flag explicitly in order to remain in your specialisation.
* You can set `specialisation.<name>.inheritParentConfig = false`, but in this case you'll need to re-specify `fileSystems` and `boot` options.

This flake fixes those problems. You can set `boot.loader.grub.defaultSpecialisation.name` to the name of the specialisation that you'd like to be selected in the boot menu by default. When you're in a specialisation, `nixos-rebuild test|switch` will remain in that specialisation, and switching from specialisation `A` to specialisation `B` is as easy as `nixos-rebuild --flake .#my-system --specialisation B test`. If you wish to run `nixos-rebuild` outside of the context of a specialisation, you can simply run `base-nixos-rebuild`. This means that you can specify your default configuration as a basic system, upon which specialisations are built.

**WARNING: This will break for specialisations named `switch` or `test`. This will be fixed in a later version.**
