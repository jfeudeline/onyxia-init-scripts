#!/bin/bash

apt-get update
apt-get install gcc 
apt-get install build-essential 
apt-get install curl
apt-get installunzip
apt-get install bubblewrap

bash -c "sh <(curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)"
