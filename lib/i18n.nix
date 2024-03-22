{lib, ...}: {
  config = {
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = lib.mkOverride 10 "us1";
      useXkbConfig = true; # use xkbOptions in tty.
    };
  };
}
