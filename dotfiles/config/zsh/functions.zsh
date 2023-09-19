#!/bin/bash

for widget in $ZDOTDIR/functions/*; do
  autoload -Uz ${widget:t}
  zle -N ${widget:t}
done
