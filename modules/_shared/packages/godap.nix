{pkgs, lib}: let
  version = "2.10.4";

  godap = pkgs.buildGoModule {
    pname = "godap";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "Macmod";
      repo = "godap";
      rev = "v${version}";
      hash = "sha256-mvzVOuFZABGE7DH3AkhOXvsvSZzgpW0aJUdXW6N6hf0=";
    };

    vendorHash = "sha256-NiNhKbf5bU1SQXFTZCp8/yNPc89ss8go6M2867ziqq4=";

    meta = {
      homepage = "https://github.com/Macmod/godap";
      description = "TUI for LDAP";
      license = lib.licenses.mit;
    };
  };
in {
  environment.systemPackages = [
    godap
  ];
}
