{pkgs}: let
  main-website-root = "/var/www/megacorp.industries";
  main-website-rev = "3eed11c387e49bc75c00261d4645767797655623";
  main-website-hash = "sha256-HRSewPtOVgWlIqi2k/Ax1/uv/3ZRKDU5wCCKrQKB50c=";

  about-website-root = "/var/www/cv.megacorp.industries";
  about-website-rev = "69455caa0c5e735ec862437d0a6afbb0b5cb8908";
  about-website-hash = "sha256-DzB9Y4B2/+eKfxyldhkHI//q4QaAOObH53JRVORCiZI=";

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
  built-hugo-root-website = build-website "hugo-website" main-website-rev main-website-hash;

  built-hugo-cv-website = build-website "about-website" about-website-rev about-website-hash;
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
      root = about-website-root;
    };
  };

  systemd.services = {
    rebuild-hugo-website = rebuild-website main-website-root built-hugo-root-website;

    rebuild-about-website = rebuild-website about-website-root built-hugo-cv-website;
  };
}
