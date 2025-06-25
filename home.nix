{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "david";
  home.homeDirectory = "/home/david";


  # Installing some stuff for editor/shell
  home.packages = [
    pkgs.oh-my-zsh
    pkgs.gcc
    pkgs.pkg-config
    pkgs.tree-sitter
    pkgs.nodejs
  ];

  # Configure zsh
  programs.zsh = {
    enable = true;
    shellAliases = {
      nrs = "pushd $HOME/.dotfiles ; sudo nixos-rebuild switch --flake . ; popd";
      hms = "pushd $HOME/.dotfiles ; nix run home-manager/master -- switch -b backup --flake . ; popd";
      nd = "nix develop";
      ndi = "nix develop --impure";
      flake-update = "pushd $HOME/.dotfiles ; nix flake update ; popd";
      vi = "nvim";
      cls = "clear";
      apt = "sudo apt";
      gh = "history | grep";
      myip = "curl http://ipecho.net/plain; echo";
      zsrc = "source ~/.zshrc";
      vip = "vi -p";
      todo = "find . -maxdepth 6 -type f  -exec grep --color=auto  -Hn \"TODO\" {} \\;";
      signout = "qtile cmd-obj -o cmd -f shutdown";
      cat = "bat";
    };
    autosuggestion.enable = true;
    enableCompletion = true;
  };

  programs.zsh.plugins = [
    {
      name = "pure";
      src = pkgs.fetchFromGitHub {
        owner = "sindresorhus";
        repo = "pure";
        rev = "v1.23.0";
        sha256 = "1jcb5cg1539iy89vm9d59g8lnp3dm0yv88mmlhkp9zwx3bihwr06";
      };
    }
  ];

  programs.zsh.oh-my-zsh = {
    enable = true;
    plugins = [
      "git"
      "ssh"
      "fzf"
      "man"
      "tmux"
    ];
    theme = "";
  };

  # Configure tmux
  programs.tmux.enable = true;
  home.activation.ohMyTmux = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Clone upstream repo if missing
    if [ ! -d "$HOME/.tmux" ]; then
      ${lib.getExe pkgs.git} clone --single-branch https://github.com/gpakosz/.tmux.git ~/.tmux
    fi
    # Link main config into home
    ln -sfn ~/.tmux/.tmux.conf ~/.tmux.conf
    # Copy local overrides template
  '';
  

  # Home Manager is pretty good at managing dotfiles.
  home.file = {
    ".config/qtile".source = ./qtile;
    ".config/alacritty".source = ./alacritty;
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
    ".tmux.conf.local".source = ./tmux.conf.local;
  };


  home.sessionVariables = {
    EDITOR = "nvim";
  };



  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
