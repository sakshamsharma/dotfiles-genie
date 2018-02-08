# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let

  i3Packages = with pkgs; {
    inherit i3-gaps i3status feh roxterm rofi-menugen networkmanagerapplet
      redshift base16 rofi rofi-pass i3lock-fancy xcape compton;
    inherit (xorg) xrandr xbacklight xset;
    inherit (pythonPackages) alot py3status;
  };

  setxkbmapPackages = with pkgs.xorg; {
    inherit xinput xset setxkbmap xmodmap; };
 
in rec {

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.buildCores = 8;
  nix.binaryCaches = ["http://hydra.nixos.org/" "http://cache.nixos.org/"];

  boot = {
    loader = {
      # grub.enable = true;
      # grub.version = 2;
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efibootmgr.efiPartition = 2;
        efiSysMountPoint = "/boot/efi";
      };
    };
    kernel.sysctl."vm.swappiness" = 10;

    extraModprobeConfig = "options rtl8723be fwlps=0";
    kernelModules = [ "bbswitch" "nvidia" ];
    kernelParams = [ "libahci.ignore_sss=1" ];

    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = "nixon";
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs;
    (builtins.attrValues (
      i3Packages //
      setxkbmapPackages //
      {})) ++
  [
    wget vim rxvt_unicode firefox git ntfs3g curl xlibs.xmodmap
    light pamixer pavucontrol networkmanagerapplet pciutils xclip
    google-chrome rofi conky spotify coq lxappearance tmux
    neovim gcc clang gnumake stack binutils bison go file pciutils
    gnuplot python3 python2 patchelf blueman unzip zip vlc gamin
    gvfs bc readline zathura ctags zlib compton blueman
    (import /etc/nixos/emacs.nix { inherit pkgs; })
  ];

  environment.etc."xmodmap/conf".text = ''
    clear control
    clear mod1
    keycode 105 = Alt_R Meta_R
    keycode 108 = Control_R
    add control = Control_L Control_R
    add mod1 = Alt_L Alt_R Meta_R
  '';

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:
  services.openssh.enable = true;
  services.emacs.enable = true;
  services.dbus.packages = with pkgs; [ blueman ];

  systemd.user.services."urxvtd" = {
    enable = true;
    description = "rxvt unicode daemon";
    wantedBy = [ "default.target" ];
    path = [ pkgs.rxvt_unicode ];
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 2;
    serviceConfig.ExecStart = "${pkgs.rxvt_unicode}/bin/urxvtd -q -o";
  };

  systemd.user.services."compton" = {
    enable = true;
    description = "";
    wantedBy = [ "default.target" ];
    path = [ pkgs.compton ];
    serviceConfig.Type = "forking";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 2;
    serviceConfig.ExecStart = "${pkgs.compton}/bin/compton -b --config /home/saksham/.compton.conf";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.xserver = {
    layout = "us";
    enable = true;

    desktopManager.xterm.enable = false;
    displayManager = {
      sddm.enable = true;
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 200 60
      '';
    };

    windowManager = {
      i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
      default = "i3";
    };

    xkbOptions = "ctrl:nocaps";
    synaptics = {
      enable = true;
      twoFingerScroll = true;
      buttonsMap = [ 1 3 2 ];
      additionalOptions = ''
        Option "SoftButtonAreas" "3471 5664 4057 8128 0 0 0 0"
        Option "ClickFinger1" "1"
        Option "ClickFinger2" "2"
        Option "ClickFinger3" "3"
        Option "TapButton1" "1"
        Option "TapButton2" "2"
        Option "TapButton3" "3"
      '';
    };
  };

  programs.zsh.enable = true;
  programs.ssh.startAgent = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.saksham = {
    home = "/home/saksham";
    isNormalUser = true;
    uid = 1000;
    description = "Saksham Sharma";
    shell = "${pkgs.zsh}/bin/zsh";
    extraGroups = [ "wheel" "networkmanager" "docker" "vboxusers" ];
  };

  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  fonts = {
      fontconfig = {
        antialias = true;
      };
      enableFontDir = true;
      enableGhostscriptFonts = true;
      fonts = with pkgs; [
          dejavu_fonts
          powerline-fonts
          google-fonts
          inconsolata
          ubuntu_font_family
          liberation_ttf
          source-code-pro
          terminus_font
          anonymousPro
          corefonts
          freefont_ttf
          emacs-all-the-icons-fonts
      ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09"; # Did you read the comment?
}
