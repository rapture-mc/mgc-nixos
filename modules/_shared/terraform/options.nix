{lib}: let
  inherit
    (lib)
    mkOption
    types
    ;
in {
  action = mkOption {
    type = types.enum [
      "apply"
      "destroy"
      "plan"
    ];
    default = "apply";
    description = "What Terraform action to perform";
  };

  state-dir = mkOption {
    type = types.path;
    default = "";
    description = "Where to store the Terranix state files";
  };
}
