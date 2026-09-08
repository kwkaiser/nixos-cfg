{ mkModuleOption, ... }:
{
  options.darwin.modules.sikarugir = mkModuleOption { };

  config.darwin.modules.sikarugir = {
    homebrew.taps = [ "Sikarugir-App/sikarugir" ];
    homebrew.casks = [ "Sikarugir-App/sikarugir/sikarugir" ];

    system.activationScripts.postActivation.text = ''
      if [ "$(uname -p)" = "arm" ] && ! /usr/bin/arch -x86_64 /usr/bin/true >/dev/null 2>&1; then
        softwareupdate --install-rosetta --agree-to-license
      fi
    '';
  };
}
