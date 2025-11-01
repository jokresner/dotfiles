{
  description = "jokresner nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
	nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, ... }:
  let
    darwin-configuration = { pkgs, ... }: {
	  nixpkgs.config.allowUnfree = true;

	  nix.enable = false;

      environment.systemPackages =
        [ pkgs.neovim pkgs.nushell pkgs.home-manager
        ];

	  homebrew = {
		enable = true;
		brews = [
			"adembc/tap/lazyssh"
			"asdf"
			"ast-grep"
			"atuin"
			"bat"
			"carapace"
			"curl"
			"fastfetch"
			"fd"
			"ffmpeg"
			"git-lfs"
			"htop"
			"jq"
			"keychain"
			"lazydocker"
			"lazygit"
			"luarocks"
			"neovim-remote"
			"nushell"
			"pass"
			"pkl"
			"rainfrog"
			"ripgrep"
			"spicetify-cli"
			"starship"
			"typst"
			"unp"
			"uv"
			"wget"
			"yadm"
			"yazi"
			"zellij"
			"zoxide"
		];
		casks = [
			"nikitabobko/tap/aerospace"
			"anytype"
			"appcleaner"
			"blip"
			"cursor"
			"font-fira-code-nerd-font"
			"font-rubik"
			"ghostty"
			"git-credential-manager"
			"iina"
			"latest"
			"legcord"
			"nextcloud"
			"raycast"
			"remarkable"
			"scroll-reverser"
			"setapp"
			"termius"
			"yaak"
			"zed"
		];
	  };

      nix.settings.experimental-features = "nix-command flakes";

	  system.primaryUser = "johannes";

      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    darwinConfigurations."darwin" = nix-darwin.lib.darwinSystem {
      modules = [ 
	  		darwin-configuration 
	  		nix-homebrew.darwinModules.nix-homebrew
			{
				nix-homebrew = {
					enable = true;
					enableRosetta = true;

					user = "johannes";

					autoMigrate = true;
				};
			}
	  ];
    };

	darwinPackages = self.darwinConfigurations."darwin".pkgs;
  };
}
