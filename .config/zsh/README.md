### zsh configuration

The configuration is split into two parts: fixed and optional. The fixed parts are in `config.d` and are always set, optional configurations live in `optional.d` and can be symlinked to the `config.d` directory to enable them.

Enable a setting:

```sh
cd ~/.config/zsh/config.d
ln -s ../optional.d/40-use-nvim .
```

The symlinks are ignored via `.gitignore` as long as they follow this pattern:

- `00` - `09`: Reserved
- `10` - `39`: Fixed configuration
- `40` - `79`: Optional configuration
  - `4X`: programs
  - `5X`: OS specific fixes and tweaks
  - `6X`: scripts
  - `7X`: programming languages
- `80` - `99`: Local configuration (not checked in)
