{
  description = ''
    More ergonomic specialisations for NixOS.
  '';
  outputs = _: {
    nixosOptions.default = ./options.nix;
    nixosModules.default = ./config.nix;
  };
}
