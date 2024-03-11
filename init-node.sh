#!/bin/bash

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
apt-get install -y ca-certificates curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

apt-get update
apt-get install nodejs -y

