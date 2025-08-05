{osConfig, ...}: let
  cfg = osConfig.megacorp;
in {
  imports = [fastfetch/default.nix];

  # Makes directories pink
  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
    settings.DIR = "0;32";
  };

  programs = {
    zsh = {
      enable = true;
      loginExtra = "fastfetch";
      autosuggestion.enable = true;
      sessionVariables = {
        TERM = "xterm-256color";
        EDITOR = "vim";
      };

      shellAliases = {
        v = "vi";
        nix-list-generations = "nix profile history --profile /nix/var/nix/profiles/system";
      };

      oh-my-zsh = {
        enable = true;
        theme = "fino-time";
        plugins = [
          "tmux"
          "aws"
          "${
            if cfg.services.k3s.role == "server" && cfg.services.k3s.enable
            then "kubectl"
            else ""
          }"
        ];
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    lsd.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
