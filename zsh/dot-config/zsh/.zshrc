#!/usr/bin/env zsh

for f in ~/.config/zsh/config.d/*; do
  . "${f}";
done

