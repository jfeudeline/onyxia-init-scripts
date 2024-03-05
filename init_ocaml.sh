#!/bin/bash

sudo apt-get update
sudo apt-get install gcc 
sudo apt-get install build-essential 
sudo apt-get install curl
sudo apt-get installunzip
sudo apt-get install bubblewrap

sudo bash -c "sh <(curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)"
