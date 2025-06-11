_: {
  imports = [fastfetch/default.nix];

  programs = {
    nushell = {
      enable = true;
      loginFile.text = ''
        $env.config.buffer_editor = "nvim"
        $env.config.show_banner = false
        fastfetch
      '';

      shellAliases = {
        v = "vi";
        ra = "ranger";
        l = "ls";
        ll = "ls -l";
        lla = "ls -la";
        nix-list-generations = "nix profile history --profile /nix/var/nix/profiles/system";

        # No tmux plugin exists for nushell (as oppose to oh-my-zsh's tmux plugin so need to manually declare them)
        ta = "tmux attach -t";
        tkss = "tmux kill-session -t";
        tl = "tmux list-sessions";
        ts = "tmux new-session -s";
      };
    };

    zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
