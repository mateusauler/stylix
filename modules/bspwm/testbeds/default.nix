{ lib, pkgs, ... }:

{
  config.stylix.testbed.ui = {
    graphicalEnvironment = "bspwm";

    # We need something to open a window so that we can check the window borders
    command.text = lib.getExe pkgs.kitty;
  };
}
