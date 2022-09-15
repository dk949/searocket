# searocket prompt

[spaceship prompt](https://github.com/spaceship-prompt/spaceship-prompt) is
pretty good... but it was getting a bit sluggish for my liking. So I made this
slimmed down version which does all the heavy lifting in D.

## Build and install

It is recommended to use
[ldc](https://github.com/ldc-developers/ldc#installation), but
[dmd](https://dlang.org/download.html#dmd) is also supported.

Requires [dub](https://github.com/dlang/dub/releases) and `make` (technically
doesn't require make, you can just read the `Makefile` and do the same thing
manually).

Use the `PREFIX` and `ZSH_FILE_LOCATION` environment variables to set the prefix
and the location of the zsh file (or use the defaults.)

``` sh
make
PREFIX=/path/to/prefix ZSH_FILE_LOCATION=/path/to/searocket/zsh/file make install
```

You will need to source the `searocket.zsh` file from your `.zshrc`. E.g.:

``` sh
echo ". /path/to/searocket.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc"
```

## Config

This part will be improved in the next refactor

The basic idea is that all configuration is done at compile time. This would
require the user to have the [D toolchain](https://dlang.org/download.html)
setup.

Integrations can be enabled by adding to the `versions` array in `dub.json`.

Enabling more integrations will cause the prompt to be slower, but this is not
very perceptible.

It is currently not possible to control colors, symbols or order (former two are
planned for the future). NOTE: this means that (for now) if your terminal does
not support emoji the symbols for Python (🐍) and Node (⬢ ) will not show up
correctly (symbol for Node might not work even if you have emoji support).

### supported `versions` values

* git
* D
* python
* nodejs
* nodejsglobalversion
  * if `.nvmrc` is not present, query the `node` executable for node version.
* battery
* haskell
* rust
* zig

## TODO

### Integrations (roughly in order of importance)

* [x] git
* [x] D
* [x] python
* [x] nodejs (with venison number!!)
* [ ] laptop battery
* [ ] haskell
* [ ] rust
* [ ] zig

### Configuration

* [x] selectively enable integrations
* [ ] Configuring colors of different parts of the prompt
* [ ] Configuring symbols used for various
* [ ] Set how long a program needs to run before the "took: ###" rprompt is
  shown.

## Development

To test the prompt during development, start a zsh session with the default
prompt, then source the `envsetup` file. If an error shows up, run any command
(I tend to use `clear`) and it should disappear.

At the end, either run the `envtaredown` function, or just exit zsh.

## License

Most of the code is written by me and licensed under the MIT license (see
`LICENSE` file).

Regular expressions used for parsing git status are from the spaceship prmpt
project and are licensed under the MIT license (see [spaceship prompt
LICENSE.md](https://github.com/spaceship-prompt/spaceship-prompt/blob/master/LICENSE.md)).
