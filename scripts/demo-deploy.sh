#!/bin/bash
# Merge la branche `dev` dans la branche `master`.
# CircleCI déploie automatiquement la branche `master` sur l'environnement de démo.

git fetch --all
git checkout dev && git pull --rebase
git checkout master && git pull --rebase

echo "Changements depuis le dernier merge de la branche dev dans master:"
GIT_PAGER=cat git log master..dev --oneline

read -p "Êtes-vous sûr de vouloir merger ces commits dans master ? [o/N]" -n 1 -r
echo
if [[ $REPLY =~ ^[Oo]$ ]]
then
  git checkout master
  git merge --no-ff --no-edit dev
  git push upstream master:master
fi
