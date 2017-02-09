#!/bin/bash
# Tag le commit en cours comme étant déployable en production.
# CircleCI déploie automatiquement en production les tags de la forme `production-*`.

# Termine le script à la première commande en erreur
set -e

branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" != "master" ]; then
  echo "Seuls les commits de la branche 'master' devraient être déployés en production – mais la branche actuelle est '$branch'."
  echo "Placez-vous sur la branche 'master' pour continuer."
  exit 1
fi

echo "Changements depuis le dernier tag:"
GIT_PAGER=cat git log `git describe --tags --abbrev=0 HEAD^`..HEAD --oneline

read -p "Êtes-vous sûr de vouloir tagger ces commits pour la production ? [o/N]" -n 1 -r
echo
if [[ $REPLY =~ ^[Oo]$ ]]
then
  REVISION=`git rev-parse --short HEAD`
  git tag "production-${REVISION}"
  echo "Le tag 'production-${REVISION}' a été créé."
  echo "Maintenant utilisez 'git push --tags' pour publier le tag,"
  echo "et déclencher le déploiement en production."
fi
