let
  # https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/17
  extension = shortId: uuid: {
      name = uuid;
      value = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${shortId}/latest.xpi";
        installation_mode = "force_installed";
      };
    };

in {
  programs.firefox = {
    enable = true;
    policies.ExtensionSettings = builtins.listToAttrs [
      (extension "ublock-origin" "uBlock0@raymondhill.net")
      (extension "vimium-ff" "{d7742d87-e61d-4b78-b8a1-b469842139fa}")
      (extension "multi-account-containers" "@testpilot-containers")
      (extension "temporary-containers" "{c607c8df-14a7-4f28-894f-29e8722976af}")
      (extension "facebook-container" "@contain-facebook")
      (extension "old-reddit-redirect" "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}")
    ];

    profiles = {
      profile_0 = {
        id = 0;
        name = "sigurds_profile";
        isDefault = true;
      };
    };
  };
}
