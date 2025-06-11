{
  lib,
  config,
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
      keymaps = [
        {
          action = "<cmd>Oil<CR>";
          key = "<C-n>";
          mode = "n";
        }
        {
          action = "<cmd>Telescope live_grep<CR>";
          key = "<leader>t";
          mode = "n";
        }
        {
          action = "<cmd>LazyGit<CR>";
          key = "<leader>g";
          mode = "n";
        }
        {
          action = "<cmd>BufferPrevious<CR>";
          key = "<A-,>";
          mode = "n";
        }
        {
          action = "<cmd>BufferNext<CR>";
          key = "<A-.>";
          mode = "n";
        }
        {
          action = "<cmd>BufferClose<CR>";
          key = "<A-c>";
          mode = "n";
        }
        {
          action = "<cmd>BufferRestore<CR>";
          key = "<A-s-c>";
          mode = "n";
        }
      ];
    };
  };
}
