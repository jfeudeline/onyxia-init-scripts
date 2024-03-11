#!/bin/bash

# On enregistre tous les logs dans log.out pour pouvoir déboguer
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1

# Pareil pour les variables d'environnement
env | sort > env_init.out

# Et pour le script d'initialisation utilisé
wget -O init_originel.sh ${PERSONAL_INIT_SCRIPT}



apt-get update
apt-get install -y bubblewrap
apt-get install -y opam
opam init --disable-sandboxing -y
opam install -y ocaml-lsp-server odoc ocamlformat utop
eval $(opam env)
code --install-extension ocamllabs.ocaml-platform
