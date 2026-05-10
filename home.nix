{ config, pkgs, pkgs-unstable, pim-src, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    nvim = "nvim";
    hypr = "hypr";
    waybar = "waybar";
    kitty = "kitty";
    fastfetch = "fastfetch";
    eww = "eww";
    mako = "mako";
  };
in

{
  home.username = "maxcaspar";
  home.homeDirectory = "/home/maxcaspar";
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.npm-global/bin" "$HOME/.cargo/bin" ];

  programs.bash = {
    enable = true;
    initExtra = ''
      export HERMES_HOME="$HOME/.hermes"
      eval "$(starship init bash)"
      [ -z "$IN_NIX_SHELL" ] && fastfetch
    '';
    shellAliases = {
      aria  = "PI_LINK_ID=Aria  PI_LINK_PEER=Basil PI_CENTER_ID=center pi";
      basil = "PI_LINK_ID=Basil PI_LINK_PEER=Aria  PI_CENTER_ID=center pi";
      bench = "python3 ~/python-scripts/model-benchmarks/bench.py";
      neo = "neo -c cyan -D";
      dotclaude = "cd ~/dotfiles && claude";
      dotcodex = "cd ~/dotfiles && codex";
      # Qwen 3.5 Q4_K_M - Faster, more context (262K), 37.6 t/s
      qwen354 = "llama-server -m ~/models/qwen3.5-27b/Qwen3.5-27B-Q4_K_M.gguf --host 127.0.0.1 --port 8080 -ngl 99 -fa on -c 262144 --cache-type-k q4_0 --cache-type-v q4_0 --threads 12 --jinja --alias qwen3.5-27b-q4km";
      # Qwen 3.5 Q5_K_XL - Better quality, 131K context, 31.0 t/s
      qwen355 = "llama-server -m ~/models/qwen3.5-27b/Qwen3.5-27B-UD-Q5_K_XL.gguf --host 127.0.0.1 --port 8080 -ngl 99 -fa on -c 131072 --cache-type-k q4_0 --cache-type-v q4_0 --threads 12 --jinja --alias qwen3.5-27b-q5kxl";
      # Qwen 3.6 Q4_K_M - Newer model, 131K context, 38.3 t/s (q8_0 KV)
      qwen36 = "llama-server -m ~/models/qwen3.6-27b/Qwen3.6-27B-Q4_K_M.gguf --host 127.0.0.1 --port 8080 -ngl 99 -fa on -c 131072 --cache-type-k q8_0 --cache-type-v q8_0 --threads 12 --jinja --alias qwen3.6-27b-q4km";
    };
  };

  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    extraConfig = ''
      bind C-Space send-prefix
    '';
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "maxcaspar";
      email = "git@maxcaspar.com";
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.override {
      commandLineArgs = "--enable-features=UseOzone,WaylandWindowDecorations --ozone-platform=wayland";
    };
  };

  xdg.configFile = (builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs) // {
    "starship.toml".source = create_symlink "${dotfiles}/starship.toml";
  };

  # pi-coding-agent config (in ~/.pi/agent/, not ~/.config/)
  home.file = {
    ".pi/agent/settings.json".source = create_symlink "${dotfiles}/pi/settings.json";
    ".pi/agent/extensions".source = create_symlink "${dotfiles}/pi/extensions";
  };

  home.packages = with pkgs; [
    # Pi Mail — agent-to-agent messaging CLI
    (rustPlatform.buildRustPackage {
      pname = "pim";
      version = "0.1.0";
      src = pim-src;
      cargoLock.lockFile = "${pim-src}/Cargo.lock";
    })
    # Shell, editor, and development tools.
    claude-code # Claude Code CLI
    pkgs-unstable.codex # Codex CLI from unstable nixpkgs
    starship # shell prompt
    ripgrep # fast text search
    neovim # editor
    nil # Nix language server
    nixpkgs-fmt # Nix formatter
    gcc # C compiler for Neovim parser builds
    nodejs # JavaScript runtime for tooling
    cargo # Rust package manager
    rustc # Rust compiler
    rustfmt # Rust formatter
    clippy # Rust linter
    rust-analyzer # Rust language server
    gh # GitHub CLI
    # ns: interactive nix package search using fzf
    (writeShellApplication {
      name = "ns";
      runtimeInputs = [ fzf nix-search-tv ];
      text = builtins.readFile "${nix-search-tv.src}/nixpkgs.sh";
      excludeShellChecks = [ "SC2016" ];
    })

    # General system info and monitoring.
    fastfetch # system info on terminal open
    chafa     # image-to-text for fastfetch logo
    btop # process and system monitor
    nvitop # NVIDIA GPU monitor

    # Programs
    obsidian
    google-chrome

    # Hyprland desktop utilities.
    waybar # status bar
    wofi # application launcher
    mako # notification daemon
    grimblast # screenshot helper
    wl-clipboard # clipboard tools for Wayland
    wtype # Wayland keyboard input emulator (used by voxtype for auto-submit)
    networkmanagerapplet # network tray app
    blueman # Bluetooth manager
    hyprpolkitagent # authentication agent for Hyprland
    pavucontrol # audio mixer
    playerctl # media player control CLI
    brightnessctl # brightness control CLI
    hyprpaper
    eww          # widget system for dashboard panel
    (python313.withPackages (ps: with ps; [ ps.huggingface-hub ps.hf-transfer ]))  # eww scripts + hf downloads
    jq           # used by eww weather script
    pkgs-unstable.voxtype-vulkan # push-to-talk speech transcription
    inotify-tools # used by waybar-reload service
    pkgs.nerd-fonts.commit-mono # CommitMono Nerd Font

    # ASCII
    neo
    mapscii
    browsh

    # AI Harness
    # pi-coding-agent installed via npm to ~/.npm-global

    # ComfyUI via Podman with NVIDIA GPU + SageAttention
    (writeShellScriptBin "comfyui-build" ''
      mkdir -p /mnt/hdd/containers/tmp
      TMPDIR=/mnt/hdd/containers/tmp podman build -t comfyui-sage ~/dotfiles/config/comfyui/
    '')

    (writeShellScriptBin "comfyui" ''
      case "''${1:-start}" in
        start)
          if podman ps --format '{{.Names}}' | grep -q '^comfyui$'; then
            echo "ComfyUI already running → http://localhost:8188"
          else
            mkdir -p /mnt/hdd/comfyui/{models,output,custom_nodes,input}
            podman run -d \
              --name comfyui \
              --replace \
              --device nvidia.com/gpu=all \
              -p 8188:8188 \
              -v /mnt/hdd/comfyui/models:/opt/ComfyUI/models \
              -v /mnt/hdd/comfyui/output:/opt/ComfyUI/output \
              -v /mnt/hdd/comfyui/custom_nodes:/opt/ComfyUI/custom_nodes \
              -v /mnt/hdd/comfyui/input:/opt/ComfyUI/input \
              comfyui-sage
            echo "ComfyUI started → http://localhost:8188"
          fi
          ;;
        stop)
          podman stop comfyui && podman rm comfyui
          ;;
        logs)
          podman logs -f comfyui
          ;;
        update)
          echo "Updating ComfyUI source inside container..."
          podman exec comfyui git -C /opt/ComfyUI pull
          echo "Restart with: comfyui stop && comfyui start"
          ;;
        *)
          echo "Usage: comfyui [start|stop|logs|update]"
          ;;
      esac
    '')

    # bash command to git commit and push dotfiles
    (writeShellScriptBin "nixos-commit" ''
      set -e
      if [ -z "$1" ]; then
        echo "Forgot the commit message, silly-billy :)"
        exit 1
      fi
      cd ~/dotfiles
      git add flake.nix flake.lock configuration.nix hardware-configuration.nix home.nix config
      git commit -m "$1"
      git push
    '')
  ];

  systemd.user.services.waybar-reload = {
    Unit = {
      Description = "Reload waybar on config changes";
      After = [ "waybar.service" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.writeShellScript "waybar-reload-watch" ''
        while ${pkgs.inotify-tools}/bin/inotifywait -e close_write,moved_to,create \
          "${config.home.homeDirectory}/dotfiles/config/waybar/"; do
          pkill -SIGUSR2 waybar || true
        done
      ''}";
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.voxtype = {
    Unit = {
      Description = "Voxtype push-to-talk voice-to-text daemon";
      Documentation = "https://voxtype.io";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs-unstable.voxtype-vulkan}/bin/voxtype --no-hotkey --flash-attention --auto-submit daemon";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = "XDG_RUNTIME_DIR=%t";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
