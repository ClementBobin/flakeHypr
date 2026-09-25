{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.modules.hm.utilities.time-tracker;


  # Define all available time trackers
  availableTracker = {
    solidtime = {
      packages = with pkgs; [ solidtime-desktop ];
      description = "SolidTime Desktop Time Tracker";
    };
  };

  trackerNames = builtins.attrNames availableTracker;
  trackerPackages = lib.unique (lib.concatMap (tracker: availableTracker.${tracker}.packages) cfg.enabledTrackers);

in {
  options.modules.hm.utilities.time-tracker = {
    enabledTrackers = lib.mkOption {
      type = lib.types.listOf (lib.types.enum trackerNames);
      default = [];
      description = "List of time trackers to enable";
    };
  };

  config = lib.mkIf (cfg.enabledTrackers != []) {
    home.packages = trackerPackages;
  };
}