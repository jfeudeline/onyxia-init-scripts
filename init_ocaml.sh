#!/bin/bash

apt-get update
apt-get install -y bubblewrap
apt-get install -y opam
opam init --disable-sandboxing -y
opam install -y ocaml-lsp-server odoc ocamlformat utop
eval $(opam env)
code --install-extension ocamllabs.ocaml-platform
