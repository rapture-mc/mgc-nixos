# See https://github.com/NixOS/nixpkgs/issues/395919 for context
final: prev: {
  guacamole-server = prev.guacamole-server.overrideAttrs (finalAttrs: previousAttrs: {
    src = prev.fetchFromGitHub {
      owner = "apache";
      repo = "guacamole-server";
      rev = "acb69735359d4d4a08f65d6eb0bde2a0da08f751";
      hash = "sha256-rqGSQD9EYlK1E6y/3EzynRmBWJOZBrC324zVvt7c2vM=";
    };

    patches = [];
  });
}
