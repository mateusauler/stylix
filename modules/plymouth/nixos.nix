{
  mkTarget,
  pkgs,
  lib,
  ...
}:
mkTarget {
  name = "plymouth";
  humanName = "the Plymouth boot screen";

  extraOptions = {
    logo = lib.mkOption {
      description = "Logo to be used on the boot screen.";
      type = with lib.types; either path package;
      defaultText = lib.literalMD "NixOS logo";

      default = "${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake.png";
    };

    logoAnimated = lib.mkOption {
      description = ''
        Whether to apply a spinning animation to the logo.

        Disabling this allows the use of logos which don't have rotational
        symmetry.
      '';
      type = lib.types.bool;
      default = true;
    };
  };

  imports = [
    (lib.mkRemovedOptionModule [ "stylix" "targets" "plymouth" "blackBackground" ]
      "This was removed since it goes against the chosen color scheme. If you want this, consider disabling the target and configuring Plymouth by hand."
    )
  ];

  configElements =
    { cfg, colors }:
    let
      themeScript = import ./theme-script.nix { inherit lib cfg colors; };

      theme = pkgs.runCommand "stylix-plymouth" { } ''
        themeDir="$out/share/plymouth/themes/stylix"
        mkdir -p $themeDir

        ${lib.getExe' pkgs.imagemagick "convert"} \
          -background transparent \
          -bordercolor transparent \
          ${
            # A transparent border ensures the image is not clipped when rotated
            lib.optionalString cfg.logoAnimated "-border 42%"
          } \
          ${cfg.logo} \
          $themeDir/logo.png

        cp ${themeScript} $themeDir/stylix.script

        echo "
        [Plymouth Theme]
        Name=Stylix
        ModuleName=script

        [script]
        ImageDir=$themeDir
        ScriptFile=$themeDir/stylix.script
        " > $themeDir/stylix.plymouth
      '';
    in
    {
      boot.plymouth = {
        theme = "stylix";
        themePackages = [ theme ];
      };
    };
}
