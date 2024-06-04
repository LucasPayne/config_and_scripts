My Linux configuration files. These mostly shouldn't depend on distro, and are intended to work across multiple Linux machines.

The config locations and the `apply` script attempt to be XDG-aware whenever possible (see the [XDG specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)).

The `apply` script is basically a minimal implementation of the idea of GNU Stow, creating symlinks into this repo in the home directory, in the random places programs look for them (e.g. dpkg looks for `~/.dpkg.cfg`).
This script also does other things, such as set up symlinks to system directories for helpful navigation of non-local configuration (such as global XDG directories).
As this places files in this repo, the `apply` script generates a `.gitignore` file.

This repo also contains general scripts under `./scripts`, which the relevant shell config files should include in the PATH.

```
cd ~
# Clone config_and_scripts into ~/config.
git clone git@github.com:LucasPayne/config_and_scripts.git config

cd config
./apply
```
