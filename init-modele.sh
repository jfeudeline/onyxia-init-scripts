#!/bin/bash

# On enregistre tous les logs dans log.out pour pouvoir déboguer
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1

# Pareil pour les variables d'environnement
env | sort > env_init.out

# Et pour le script d'initialisation utilisé
wget -O init_originel.sh ${PERSONAL_INIT_SCRIPT}

#######################
# A ADAPTER
export GITLAB_USER_NAME="S.Allain" # nom d'utilisateur Gitlab
# PREALABLE
# avoir configuré le service ("Configuration RStudio") avec
# + Onglet Init : https://minio.lab.sspcloud.fr/samuelallain/init.sh dans PersonalInit, à adapter à l'emplacement de votre script
# + Onglet Git : mis une URL (ici https://git.drees.fr/DREES_code/OSAM/besp/tutos.git) ET un jeton d'accès dans Token (voir la doc du SSP Cloud)
########################

# On récupère le nom d'utilisateur SSP Cloud à partir du dossier de secrets
export SSP_USER_NAME=${VAULT_TOP_DIR:1}

# Se mettre dans le dossier work
if [[ -d "work" ]]
then
  cd work
fi

# Cloner le projet
export url="https://${GITLAB_USER_NAME}:${GIT_PERSONAL_ACCESS_TOKEN}@${GIT_REPOSITORY:8}"
git clone ${url}

# Récupérer le nom du dossier créé
# pour les opérations suivantes
export dossier=`echo $GIT_REPOSITORY | rev | cut -d "/" -f 1 | rev` # astuce pour ne garder que le dernier terme en coupant par "/"
export dossier=`echo $dossier | cut -d "." -f 1`
export dossier="/home/onyxia/work/$dossier"

# Remarque : lorsqu'on pousse on continue d'avoir un avertissement "fatal: unable to connect to cache daemon: Permission denied"
# qui est lié à un problème de droits sans doute. Ca fonctionne tout de même.

########################
# On actualise le script d'initialisation sur MinIO avec la version du dépôt
export cheminInitMinio='s3/samuelallain/init.sh'
export cheminInitLocal="${dossier}/contenu/init.sh"

# mc cp $cheminInitLocal $cheminInitMinio && # copie de la version locale vers Minio
#   mc anonymous set download $cheminInitMinio && # on rend le fichier téléchargeable sans authentification
#   mc share download $cheminInitMinio # si besoin on récupère l'URL à mettre dans la configuration du service
#mc cat $cheminInitMinio # vérif

########################
# Configuration des Global Options de RStudio

export XDG_CONFIG_HOME="/home/onyxia/.config/rstudio"
# export XDG_CONFIG_HOME="~/.config/rstudio" # ne marche pas bizarrement

# Le dossier de configuration de RStudio n'existe pas encore, preuve :
# find /home/onyxia/.config/

# On le crée
mkdir -p $XDG_CONFIG_HOME

# On fait sa propre configuration dans Tools > Global Options
# ensuite on récupère cette configuration sous la forme d'un code
# en copiant le contenu de la commande suivante :
# cat ${XDG_CONFIG_HOME}/rstudio-prefs.json

# On peut remplacer ensuite le contenu de la commande suivante
echo '{
    "load_workspace": false,
    "font_size_points": 11,
    "editor_theme": "Pastel On Dark",
    "posix_terminal_shell": "bash",
    "default_project_location": "~",
    "jobs_tab_visibility": "shown",
    "show_last_dot_value": true,
    "spelling_dictionary_language": "fr_FR"
}' > ${XDG_CONFIG_HOME}/rstudio-prefs.json

# Ce script est exécuté en root et donc tous les fichiers créés
# appartiennent à root ce qui empêche leur modification ensuite et
# génère des erreurs. On redonne la propriété du Home à
# l'utilisateur :
chown -R ${USERNAME}:${GROUPNAME} ${HOME}

########################
# Ouvrir automatiquement le projet cloné

export cheminRproj=`find $dossier -name '*.Rproj'`
# Idée 1 : se mettre au moins au niveau du Rproj pour n'avoir qu'à cliquer
# export RSTUDIO_CONF_FILE="/etc/rstudio/rsession.conf"
# echo "session-default-working-dir=$dossier" >> ${RSTUDIO_CONF_FILE}
# n'a pas fonctionné, en même temps il y a déjà une ligne pour session-default-working-dir

# Idée 2 : ajouter artificiellement le projet à la liste des
# derniers projets ouverts, pour qu'il s'ouvre automatiquement
# grâce à l'option "Restore most recently opened"
# Finalement ce n'est pas cette liste qui commande l'ouverture du dernier projet

# De nouveau le dossier de configuration n'existe pas encore, on le crée :
mkdir -p '/home/onyxia/.local/share/rstudio/monitored/lists/'
echo $cheminRproj > '/home/onyxia/.local/share/rstudio/monitored/lists/project_mru'

# Idée 3 : ajouter artificiellement le projet au fichier last-project-path
# qui a plus de chances de commander l'ouverture du dernier projet
mkdir -p '/home/onyxia/.local/share/rstudio/projects_settings/'
echo $cheminRproj > '/home/onyxia/.local/share/rstudio/projects_settings/last-project-path'
# FONCTIONNE !

# On rétablit la propriété à un utilisateur normal (sinon bug)
chown -R ${USERNAME}:${GROUPNAME} ${HOME}

# Idée 4 : On crée un .Rprofile (fichier R exécuté au début d'une session)
# avec le code qui permet de lancer le projet
# echo "
# chemin <- system(\"find . -name '*.Rproj'\", intern = T)
# if (length(chemin) == 0) {
#   message('Pas de .Rproj trouvé.')
# } else if (length(chemin) == 1) {
#   rstudioapi::openProject(chemin)
# } else {
#   message('Plus d\'un .Rproj trouvé')
# }
# " > ~/.Rprofile
# Erreur "RStudio not running"


########################
# Installer et sélectionner la correction orthographique française

# On peut trouver les chemins des dictionnaires avec des commandes R
# > rstudioapi::dictionariesPath()
# [1] "/usr/lib/rstudio-server/resources/dictionaries"
# > rstudioapi::userDictionariesPath()
# [1] "/home/onyxia/.local/share/rstudio/dictionaries"

# Le dossier suivant avait l'air prometteur mais en fait non
# /usr/local/lib/R/share/dictionaries

# Par contre celui-là :
# /home/onyxia/.config/rstudio/dictionaries/languages-system
# contient les dictionnaires obtenus en faisant
# Tools > Global Options > Spelling >
# Main dicitonary language > Install more
# Lors de cette manipulation, la liste des langues apparait
# jusqu'au moment où l'on valide
# Peut-être un nouveau problème de droits
# Solution alternative :
# https://support.posit.co/hc/en-us/articles/200551916
#sudo chown -R onyxia:users '/usr/lib/rstudio-server/resources' #ne suffit pas

# Après le téléchargement, les fichiers sont toujours là
# on peut les copier sur minio une première fois
# mc cp -r /home/onyxia/.config/rstudio/dictionaries/languages-system/ s3/samuelallain/dicos_rstudio

# A chaque lancement du service on récupère le dictionnaire français depuis minio
export cheminDico="/home/onyxia/.config/rstudio/dictionaries/languages-system"
mkdir -p $cheminDico

mc ls $cheminDico
# echo "==============="
mc cp s3/samuelallain/dicos_rstudio/fr_FR.aff $cheminDico
mc cp s3/samuelallain/dicos_rstudio/fr_FR.dic $cheminDico
mc cp s3/samuelallain/dicos_rstudio/fr_FR.dic_delta $cheminDico
# mc ls $cheminDico

# Si l'on a personnalisé des snippets, on peut récupérer le fichier
# correspondant
export cheminSnipMinio="s3/samuelallain/r.snippets"
export cheminSnipLocal="/home/onyxia/.config/rstudio/snippets/r.snippets"

# La première fois, il faut créer ce fichier en
# faisant ses personnalisations, puis en copiant le fichier avec minio :
# mc cp ${cheminSnipLocal} ${cheminSnipMinio}
# mc anonymous set download $cheminSnipMinio # téléchargeable par toustes

# à chaque init :
mkdir -p '/home/onyxia/.config/rstudio/snippets/'
mc cp ${cheminSnipMinio} ${cheminSnipLocal}

# Changement final des droits
# ls -al /home/onyxia # avant work a un groupe 1000
chown -R ${USERNAME}:${GROUPNAME} ${HOME}
ls -al /home/onyxia # vérif

# Environnement final (pour déboguage)
env | sort > env_final.out
