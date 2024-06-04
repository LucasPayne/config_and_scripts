My Linux configuration files. These mostly shouldn't depend on distro, and are intended to work across multiple Linux machines.

The `apply` script is basically a minimal implementation of the idea of GNU Stow, creating symlinks into this repo in the home directory, in the random places programs look for them (e.g. dpkg looks for `~/.dpkg.cfg`).

This repo also contains general scripts under `./scripts`, which the relevant shell config files should include in the PATH.

```
cd ~
# Clone config_and_scripts into ~/config.
git clone git@github.com:LucasPayne/config_and_scripts.git config

cd config
# Distribute symlinks to configuration files in relevant parts of the home directory.
./apply
```
