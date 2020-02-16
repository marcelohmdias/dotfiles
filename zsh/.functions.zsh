#!/usr/bin/env zsh

function node-register () {
  sudo ln -s -f ~/.nvm/versions/node/$1/bin/node /usr/local/bin/node
  sudo ln -s -f ~/.nvm/versions/node/$1/bin/npm /usr/local/bin/npm
  sudo ln -s -f ~/.nvm/versions/node/$1/bin/npx /usr/local/bin/npx
}

function nvm-use () {
  nvm alias default $1 && nvm use default
}

function pyserver () {
  python -m SimpleHTTPServer 9001
}

function kp () {
  local -r port="$1"
  local -r pid=$(lsof -t -i:$port)

  if [ -n "$pid" ]; then
    kill -9 "$pid"
    echo "Process $pid terminated on port $port."
  else
    echo "There is no process on port $port."
  fi
}
