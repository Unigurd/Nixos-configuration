{nurpkgs, ...}: let
  profile_name = "sigurds_profile";
  addons = nurpkgs.repos.rycee.firefox-addons;
in {
  programs.firefox = {
    enable = true;
    profiles = {
      ${profile_name} = {
        id = 0;
        name = profile_name;
        isDefault = true;
        extensions.packages = with addons; [
          ublock-origin
          vimium
          old-reddit-redirect
          facebook-container
        ];
        settings = {
          "extensions.autoDisableScopes" = 0;
        };
      };
    };
  };

  home.file.".mozilla/firefox/${profile_name}/user.js".text = ''
    user_pref("layout.css.devPixelsPerPx", "0.8");
  '';
}
