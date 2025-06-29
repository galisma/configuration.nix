{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Red y nombre de host
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Configuración regional y horaria
  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "es_ES.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  # Entorno gráfico (Plasma 6 con Wayland)
  services.xserver.enable = false;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Teclado
  console.keyMap = "es";

  # Impresión
  services.printing.enable = true;

  # Usuario
  users.users.ismael = {
    isNormalUser = true;
    description = "ismael";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Etc/hosts
  networking.hosts = {
  "192.168.1.5" = ["sai"];
  };

  # Usuarios confiables
  nix.settings.trusted-users = ["root" "ismael"];

  # Programas
  programs.firefox.enable = true;
  programs.kdeconnect.enable = true;
  nixpkgs.config.allowUnfree = true;

  # NCMPCPP override
  nixpkgs.overlays = [
    (final: prev: {
      ncmpcpp = prev.ncmpcpp.override {
        visualizerSupport = true;
        clockSupport = true;
      };
    })
  ];


  # Paquetes del sistema
  environment.systemPackages = with pkgs; [
    # ============ Editores e IDEs ============
    vim
    helix
    neovim
    vscode-fhs
    vscodium

    # ============ Entorno KDE ============
    kdePackages.kdenlive
    kdePackages.xdg-desktop-portal-kde
    kdePackages.sddm-kcm
    kdePackages.khelpcenter
    kdePackages.filelight
    kdePackages.qtmultimedia
    kdePackages.konversation
    kdePackages.kcolorchooser
    kdePackages.kcalc
    kdePackages.plasma-welcome
    kdePackages.alligator
    kdePackages.discover
    kdePackages.kdeconnect-kde
    # kdePackages.neochat 	flag as insecure
    qt6.qtwayland

    # ============ Lenguajes de programacion ============
    rustc
    php
    python314
    nodejs_24
    lua
    sbcl
    gcc
    jdk

    # ============ Haskell ============
    ghc
    haskellPackages.haskell-language-server
    haskellPackages.cabal-install
    haskellPackages.ghcid
    haskellPackages.hlint
    haskellPackages.ormolu

    # ============ Herramientas de desarrollo ============
    git
    gnumake
    sqlitebrowser
    godot
    libgcc

    # ============ Navegadores y comunicaciones ============
    chromium
    vesktop
    thunderbird

    # ============ Graficos =============
    krita
    inkscape
    blender
    gimp3

    # ============ Audio ==============
    audacity
    lmms
    musescore
    furnace

    # ============ Multimedia ============
    vlc
    mpv
    cava
    mpd
    ncmpcpp 

    #(ncmpcpp.override {
    #  visualizerSupport = true;
    #  clockSupport = true;
    #})

    mpc
    blanket
    imagemagick

    obs-studio
    media-downloader
    ffmpeg
    yt-dlp

    # ============ Utilidades del sistema ============
    nut
    usbutils
    fastfetch
    wl-clipboard
    alsa-utils
    dig
    btop
    pciutils
    gping
    libnotify
    kitty

    # ============ Utilidades de terminal ============
    tmux
    tealdeer
    zoxide
    bat
    rlwrap
    lsof
    nmap
    cmatrix

    # ============ Juegos ================
    superTuxKart
    shattered-pixel-dungeon
    #veloren
    steam
    prismlauncher
    zeroad
    
    # ============ Juegos de terminal ===============
    brogue
    nethack
	
    # ============ Productividad ============
    libreoffice-qt6-fresh
    xdg-ninja
    plantuml

    # ============ Virtualizacion ============
    virtualbox

    # ============ Ajedrez ============
    en-croissant
    stockfish

    # ============ BDDD ==============
    sqlite

    # ============ libs =============
    glfw
    libGLU
    cmake

    #python
    pylint
    rembg

    # ============ Internet ============
    tor-browser
  ];
  
  # Nerd-fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    jetbrains-mono
  ];

  # Servicios adicionales
  system.stateVersion = "25.05";

  # Experimental
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Audio (PipeWire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Mpd
  services.mpd = {
  user = "ismael";
  group = "ismael";
  enable = true;
  musicDirectory = "/home/ismael/Musica";
  playlistDirectory = "/home/ismael/.config/mpd/playlists";

  extraConfig = ''
    db_file "~/.config/mpd/database"
    state_file "~/.config/mpd/state"
    sticker_file "~/.config/mpd/sticker.sql"
    restore_paused "yes"
    auto_update "yes"

    audio_output {
      type "pipewire"
      name "My PipeWire Output"
    }

    audio_output {
      type                    "fifo"
      name                    "my_fifo"
      path                    "/tmp/mpd.fifo"
      format                  "44100:16:2"
    }
  '';
    network.listenAddress = "any";
  };

  systemd.services.mpd.environment = {
   XDG_RUNTIME_DIR = "/run/user/1000"; # User-id 1000 must match above user. MPD will look inside this directory for the PipeWire socket.
  };

  # Ssh
  services.openssh = {
  enable = true;
  ports = [ 22 ];
  settings = {
    PasswordAuthentication = true;
    AllowUsers = null;  # Allows all users by default. Can be [ "user1" "user2" ]
    UseDns = true;
    X11Forwarding = false;
    PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
  };
  };
}
