{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.steam-run ];
  hardware.steam-hardware.enable = true;
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
      extest.enable = true;
    };
  };
}
