{
  config,
  lib,
  hazelnutPackage,
  ...
}:

let
  cfg = config.programs.hazelnut;
in
{
  options.programs.hazelnut = {
    enable = lib.mkEnableOption "Hazelnut file organizer";

    package = lib.mkOption {
      type = lib.types.package;
      default = hazelnutPackage;
      defaultText = lib.literalExpression "hazelnutPackage";
      description = "Hazelnut package to use.";
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Hazelnut TOML configuration file.

        The file is copied unchanged to ~/.config/hazelnut/config.toml.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    xdg.configFile."hazelnut/config.toml".source = cfg.configFile;

    systemd.user.services.hazelnut = {
      Unit = {
        Description = "Hazelnut file organizer";
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/hazelnutd run";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
