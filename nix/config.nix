let pkgs = (import <nixpkgs> {});

in rec {
    packageOverrides = super: let self = super.pkgs; in {
        myHaskellEnv = self.haskellPackages.ghcWithPackages
            (haskellPackages: with haskellPackages; [
             ghc-mod
            ]);


        # Taken from github.com/pallavagarwal07/ConfigManagement
        my_tex_packages = with pkgs; texlive.combine {
            inherit (texlive) scheme-medium appendix changebar footmisc multirow
            overpic stmaryrd subfigure titlesec wasysym xargs bigfoot luatex lipsum
            fontawesome adjustbox collectbox wrapfig fancyhdr;
        };

        all = with pkgs; buildEnv {
            name = "all";
            paths = [
                gimp deluge pcmanfm evince patchelf binutils coq bind dnsutils
                silver-searcher htop tig sbt my_tex_packages
                gthumb gnome-screenshot scrot
            ];
        };
    };
}
