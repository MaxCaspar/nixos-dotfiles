# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-unstable, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "hermes"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.desktopManager.gnome.enable = true;

  # Minimal TTY-like login with session selection (Hyprland / GNOME).
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --greeting \"welcome to hermes\" --asterisks --remember --remember-session --sessions /run/current-system/sw/share/wayland-sessions --theme \"background=dark;border=cyan;text=white;prompt=cyan;action=#222222;input=white;button=cyan\"";
      };
    };
  };

  # Add Hyprland as an extra GDM session while keeping GNOME available.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };

  # RTX 3090 Nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
  };

  boot.kernelModules = [ "nvidia" ];

  # Virtualisation via Podman
  virtualisation = {
    containers.enable = true;

    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  hardware.nvidia-container-toolkit.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Keep Bluetooth available outside GNOME too.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General.FastConnectable = true;
      Policy = {
        ReconnectAttempts = 7;
        ReconnectIntervals = "1,2,4,8,16,32,64";
      };
    };
  };

  systemd.services.bluetooth.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "1s";
  };
  services.blueman.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.maxcaspar = {
    isNormalUser = true;
    description = "maxcaspar";
    extraGroups = [ "networkmanager" "wheel" "podman" ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    kitty
    (pkgs-unstable.llama-cpp.override { cudaSupport = true; })
    python313Packages.huggingface-hub
    python313Packages.hf-transfer
    curl
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Hermes Agent CLI
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    settings = {
      model = {
        base_url = "http://127.0.0.1:8080/v1";
        default = "qwen3.5-27b-q5kx";
      };
    };
  };

  # HDD model storage — auto-mount on boot
  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/a89afcf5-c33b-4505-b767-76566c8e68b2";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  # keyd: both Windows keys = Super.
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          leftmeta = "leftmeta";
          rightalt = "leftmeta";
          tab = "overload(meta, tab)";
        };
      };
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  system.stateVersion = "25.11"; # Did you read the comment?

}
