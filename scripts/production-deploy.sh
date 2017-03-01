#!/bin/bash
# Tag le commit en cours comme étant déployable en production.
# CircleCI déploie automatiquement en production les tags de la forme `production-*`.

# Termine le script à la première commande en erreur
set -e

# Récupère le nom de la remote principale du projet (généralement 'origin' ou 'upstream')
function remote_name {
  git remote -v | grep "github.com.sgmap" | head -n 1 | cut -f 1
}

# Vérifie que le repo se trouve bien sur la branche à tagger en production.
function assert_source_branch {
  branch=$(git rev-parse --abbrev-ref HEAD)
  if [ "$branch" != "$source_branch" ]; then
    echo "La branche actuelle est '$branch' – mais seuls des commits de la branche '$source_branch' devraient être déployés en production."
    echo "Placez-vous sur la branche '$source_branch' pour continuer."
    exit 1
  fi
}

# Vérifie que la branche source est bien à jour avec le dépôt distant.
function assert_branch_up_to_date {
  git fetch "$remote_name"
  local local_head=`git rev-parse ${source_branch}`
  local remote_head=`git rev-parse ${remote_name}/${source_branch}`
  if [[ "$local_head" != "$remote_head" ]]; then
    echo "La branche locale '$source_branch' n’est pas à jour avec '${remote_name}/${source_branch}'."
    echo "Récupérez les changements avec 'git pull' avant de continuer."
    exit 1
  fi
}

# Affiche les commits qui vont partir en production.
function print_changelog {
  echo "Changements depuis le dernier tag:"
  GIT_PAGER=cat git log `git describe --tags --abbrev=0 HEAD^`..HEAD --oneline --no-merges
}

# Demande une confirmation avant de créer le tag.
function confirm_tag {
  read -p "Êtes-vous sûr de vouloir tagger ces commits pour la production ? [o/N]" -n 1 -r
  echo
  if ! [[ $REPLY =~ ^[Oo]$ ]]; then
    exit 1
  fi
}

# Crée le tag de production, et affiche un message avec les étapes suivantes.
function create_production_tag {
  local revision=`git rev-parse --short HEAD`
  local date=`date +"%d/%m/%Y"`
  local tag="production-${revision}-${date}"
  git tag "$tag"

  echo
  echo "Le tag '${tag}' a été créé."
  echo "Maintenant utilisez 'git push --tags' pour publier le tag,"
  echo "et déclencher le déploiement en production."
}

# Configuration des branches
source_branch="master"
remote_name=$(remote_name)

# Exécution du script
assert_source_branch
assert_branch_up_to_date
print_changelog
confirm_tag
create_production_tag
