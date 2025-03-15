let
  module = {
    pkgs,
    config,
    lib,
    ...
  }: {
    services.jellyfin = {
      enable = true;
      # openFirewall = true;
    };
    environment.systemPackages = [pkgs.jellyfin pkgs.jellyfin-web pkgs.jellyfin-ffmpeg];
  };
in
  module
