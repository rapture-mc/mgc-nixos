{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.megacorp.programs.nixvim;

  inherit
    (lib)
    mkIf
    ;
in {
  config = mkIf cfg.enable {
    programs.nixvim = {
      plugins = {
        # CMP and LMP completion
        cmp-nvim-lsp.enable = true;
        cmp = {
          enable = true;
          autoEnableSources = true;
          filetype.markdown.completion.autocomplete = false;  # Inserting links with [text](url) generates cmp errors with each subsequent keystroke... So disabling it here - 2025-06-09
          settings = {
            sources = [
              {name = "nvim_lsp";}
              {name = "buffer";}
              {name = "path";}
              {name = "cmdline";}
            ];
            mapping = {
              "<C-j>" = "cmp.mapping.select_next_item()";
              "<C-k>" = "cmp.mapping.select_prev_item()";
              "<C-S-j>" = "cmp.mapping.scroll_docs(4)";
              "<C-S-k>" = "cmp.mapping.scroll_docs(-4)";
              "<C-Space>" = "cmp.mapping.complete()";
            };
          };
        };
        lsp = {
          enable = true;
          servers = {
            nixd = {
              enable = true;
              settings = let
                flake = ''(builtins.getFlake "github:rapture-mc/mgc-machines)""'';
              in {
                nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
                options.nixos.expr = ''${flake}.nixosConfigurations.MGC-LT01.options'';
              };
            };
            ts_ls.enable = true;
            gopls.enable = true;
            terraformls.enable = true;
            clangd.enable = true;
          };
        };

        lsp-lines.enable = true;
        alpha = {
          enable = true;
          theme = "startify";
        };
        web-devicons.enable = true;
        lualine.enable = true;
        noice.enable = true;
        nui.enable = true;
        oil = {
          enable = true;
          settings = {
            view_options = {
              show_hidden = true;
            };
          };
        };
        telescope.enable = true;
        treesitter.enable = true;
        barbar.enable = true;
        gitgutter.enable = true;
        comment.enable = true;
        autoclose.enable = true;
        ts-autotag.enable = true;
        ledger.enable = true;
      };
      extraPlugins = with pkgs.vimPlugins; [
        lazygit-nvim
        vim-table-mode
      ];
    };
  };
}
