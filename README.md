dotfiles-genie
==============

```
 _____            _
|  __ \          (_)
| |  \/ ___ _ __  _  ___
| | __ / _ \ '_ \| |/ _ \
| |_\ \  __/ | | | |  __/
 \____/\___|_| |_|_|\___|
```

My configuration management system, a mix of ideas from [GNU stow](https://www.gnu.org/software/stow/), [vcsh](https://github.com/RichiH/vcsh), [Mr](http://joeyh.name/code/mr/), [ConfigManagement](https://github.com/pallavagarwal07/ConfigManagement/) and some other utilities.

## Some awesome things
* Uses Python, so easy to set up on a fresh installation (I'd have it written in Haskell, but installing GHC isn't exactly a small task)
* Supports various different types of config managements.
* Encourages you to keep vast configurations in different repositories, and symlink them as required.
* A single configuration file to manage all your configs.
* By default, everything is symlinked. So if you need to modify any config, do it wherever, and later come back to commit and push.
* All your configs reside in a single folder, easy to track and commit changes.

## How to use
1. Place the `genie.py` script at any convenient location.
2. Copy all your configurations in a convenient folder. You don't need to clone repos if they're online. There's a separate way to clone repos automatically (Infact, this is the recommended way)
3. Place a `conf.yml` config file in that same folder. It is structured using standard YAML syntax. Look at the provided sample one for inspiration.
4. Run the genie.py script and point it to the configuration file. Example: `./genie.py ./my-dot-files/conf.yml`
5. Your configs would be linked to your home folder now. You would have symlinks to configs by default, so you can edit them all in one place.
6. Report any bug encountered here on GitHub as an issue. I'll be responsive, I promise :)
7. Feel free to send PRs

#### Fun fact
The initial 250 LOC were written on a train trip back to home.
