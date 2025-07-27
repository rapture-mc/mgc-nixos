{ lib, stdenvNoCC, fetchFromGitHub, ... }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "win95-plus-theme";
  version = "1.0.0";


  src = ../../../resources/Icons/Win95_plus;  # directory containing icons_32x32 etc. Ressources/Icons/Win95_plus/index.theme

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons/Win95_plus/{32x32,256x256,512x512,1024x1024}/apps

    cp -a $src/32x32/apps/*.png $out/share/icons/Win95_plus/32x32/apps/
    cp -a $src/256x256/apps/*.png $out/share/icons/Win95_plus/256x256/apps/ || true
    cp -a $src/512x512/apps/*.png $out/share/icons/Win95_plus/512x512/apps/
    cp -a $src/1024x1024/apps/*.png $out/share/icons/Win95_plus/1024x1024/apps/

    # Use the provided index.theme (preferred)
    if [ -f "$src/index.theme" ]; then
      cp $src/index.theme $out/share/icons/Win95_plus/index.theme
    else
      # fallback to hardcoded theme
      cat > $out/share/icons/Win95_plus/index.theme <<EOF
      
[Icon Theme]
Name=Win95_plus
Comment=Custom icon theme based on Windows 95
Inherits=Chicago95
Directories=32x32/apps,256x256/apps,512x512/apps,1024x1024/apps

[32x32/apps]
Size=32
Context=Applications
Type=Fixed

[256x256/apps]
Size=256
Context=Applications
Type=Fixed

[512x512/apps]
Size=512
Context=Applications
Type=Fixed

[1024x1024/apps]
Size=1024
Context=Applications
Type=Fixed
EOF
    fi

    runHook postInstall
  '';

  meta = {
    description = "Custom Win95-like icon theme";
    homepage = "";
  };
})
