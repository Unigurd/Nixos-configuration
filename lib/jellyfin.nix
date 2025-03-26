let
  module = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options = {
      gurd.jellyfin = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };
    };
    config = {
      services.jellyfin = {
        enable = config.gurd.jellyfin.enable;
        openFirewall = config.gurd.jellyfin.openFirewall;
      };
      environment.systemPackages = [pkgs.jellyfin pkgs.jellyfin-web pkgs.jellyfin-ffmpeg];
    };
  };
in
  module
