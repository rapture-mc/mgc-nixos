# See https://github.com/NixOS/nixpkgs/issues/395919 for context
final: prev: {
  freerdp = prev.freerdp.overrideAttrs (finalAttrs: previousAttrs: {
    patches = [
      (prev.fetchpatch2 {
        url = "https://github.com/FreeRDP/FreeRDP/commit/67fabc34dce7aa3543e152f78cb4ea88ac9d1244.patch";
        hash = "sha256-kYCEjH1kXZJbg2sN6YNhh+y19HTTCaC7neof8DTKZ/8=";
      })
    ];

    postPatch =
      ''
        # skip NIB file generation on darwin
        substituteInPlace "client/Mac/CMakeLists.txt" "client/Mac/cli/CMakeLists.txt" \
          --replace-fail "if(NOT IS_XCODE)" "if(FALSE)"

        substituteInPlace "libfreerdp/freerdp.pc.in" \
          --replace-fail "Requires:" "Requires: @WINPR_PKG_CONFIG_FILENAME@"

        substituteInPlace client/SDL/SDL2/dialogs/{sdl_input.cpp,sdl_select.cpp,sdl_widget.cpp,sdl_widget.hpp} \
          --replace-fail "<SDL_ttf.h>" "<SDL2/SDL_ttf.h>"
      ''
      + prev.lib.optionalString (prev.pcsclite != null) ''
        substituteInPlace "winpr/libwinpr/smartcard/smartcard_pcsc.c" \
          --replace-fail "libpcsclite.so" "${prev.lib.getLib prev.pcsclite}/lib/libpcsclite.so"
      '';

    nativeBuildInputs =
      previousAttrs.nativeBuildInputs
      ++ [
        prev.writableTmpDirAsHomeHook
      ];
  });
}
