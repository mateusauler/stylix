{
  lib,
  ...
}:
{
  config = {
    stylix.testbed.ui.graphicalEnvironment = "kde";
    services.displayManager.autoLogin.enable = lib.mkForce false;
  };
}
