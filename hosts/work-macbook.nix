{ inputs, system, lib, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-darwin";
  system.stateVersion = 5;

  mine.username = "karl";
  mine.homeDir = "/Users/karl";
  mine.primarySshKey =
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSHiO1udAkk/aq6l5Gojw1GWmz/2vDl/JMTot8VgaOgXyDBMRdQZw7HpyeNNY0DZszLi9u9cr2aG57H6yhId7C9PQiH75KZUsJYIpbNzRuetrXIpPBCccERB1L456P3X6Yo9N65pMAOSaL1YHkNP1a4TL3/qatm284u31hUBKq4/+t+D1U4uhG2RqT0bTgpzDW6zvHFDhR4Knnqon/2NX8+Hpv9jb0k9zMh16RBXrnMTbOEoXegdtrHZf91xIdZaOeQ20dnJv19bUJDP1m0Ynxr1XVZnHrD+bO1hohA+1tkcrfX+EVBDM5872oa4Ek8GQZIZoazqzjcdd6+/tHJM2yG66dlttPtfe/UaPo2JTiXqIaUubYdpQ+7kwWNOX605QT10mhIP3EG8/bxmM7p5CnsMXC5oG5jDcsMu8GlXtBweAXa9FvCBMQq/aVaC3HKIW1QABBlLxp9hxLeG45ptPaNSJG5MAlcrHXNAQvLJvv5pjs55K8FXO2s9smsOqXnLM= (encrypted)";
  mine.email = "karl@kwkaiser.io";

  homebrew.enable = true;
  homebrew.brewPrefix = "/opt/homebrew/bin";

  mine.aero.enable = true;
  mine.git.signsCommits = true;
  mine.node.enable = false;
  mine.neovim.enable = true;
  mine.zsh.enable = true;
  mine.keepass.enable = true;
  mine.syncthing.enable = true;
  mine.cursor.enable = true;
  mine.steam.enable = true;
  mine.notes = {
    enable = true;
    untrusted = true;
  };
  mine.messaging.enable = true;
  mine.ssh.enable = true;
  mine.virt.enable = true;
}
