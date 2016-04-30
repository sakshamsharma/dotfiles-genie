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

## How to use
1. Place the `genie.py` script at any convenient location.
2. Copy all your configurations in a convenient folder.
3. Place a `conf.yml` config file in that same folder. It is structured using standard YAML syntax. Look at the provided sample one for inspiration.
4. Run the genie.py script and point it to the configuration file. Example: `./genie.py ./my-dot-files/conf.yml`
5. Your configs would be linked to your home folder now. You would have symlinks to configs by default, so you can edit them all in one place.
6. Report any bug encountered here on GitHub as an issue. I'll be responsive, I promise :)
7. Feel free to send PRs

#### Fun fact
The initial 250 LOC were written on a train trip back to home.
