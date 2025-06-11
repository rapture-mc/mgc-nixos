{pkgs}: let
  main-website-root = "/var/www/megacorp.industries";

  cv-website-root = "/var/www/cv.megacorp.industries";

  # Helper function to build hugo website deriviationn
  build-website = repo: rev: hash:
    pkgs.stdenv.mkDerivation {
      name = repo;

      src = pkgs.fetchFromGitHub {
        owner = "rapture-mc";
        repo = repo;
        rev = rev;
        hash = hash;
      };

      installPhase = ''
        mkdir $out

        ${pkgs.hugo}/bin/hugo

        cp -rv public $out
      '';
    };

  # Helper function to generate systemd service that deploys built hugo website to nginx root folder
  rebuild-website = website-root: website-source: {
    enable = true;
    description = "Rebuilds hugo website";
    script = ''
      if [ ! -d ${website-root} ]; then
        echo "Website directory doesn't exist, creating..."
        mkdir -p ${website-root}

        echo "Setting permissions on newly created directory..."
        chown nginx:nginx ${website-root}
      fi

      ${pkgs.rsync}/bin/rsync -avz --delete ${website-source}/public/ ${website-root}
      chown -R nginx:nginx ${website-root}
    '';
    unitConfig.Before = "nginx.service";
    wantedBy = ["multi-user.target"];
  };

  # Deriviations containing the built hugo website
  built-hugo-root-website = build-website "hugo-website" "4ac806a65054ecc4a46f2e4d77e034a60b98c2e3" "sha256-4oSqxuvkVj5QZ0RP9dI0SQ4WLmO8v5K1Z4Xue5uOg5M=";

  built-hugo-cv-website = build-website "hugo-terminal" "fe9d1cbc033f0fc14e554f9e437ce1f03560d511" "sha256-u4ab3eYSlBwRevOohCZ5w2LB3JWXnST+khMPikcCK2U=";
in {
  services.nginx.virtualHosts = {
    "megacorp.industries" = {
      forceSSL = true;
      enableACME = true;
      root = main-website-root;
      extraConfig = ''
        error_page 404 /404.html;
      '';
    };

    "cv.megacorp.industries" = {
      forceSSL = true;
      enableACME = true;
      root = cv-website-root;
    };
  };

  systemd.services = {
    rebuild-hugo-website = rebuild-website main-website-root built-hugo-root-website;

    rebuild-about-website = rebuild-website cv-website-root built-hugo-cv-website;
  };
}
