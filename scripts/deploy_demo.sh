#!/bin/bash
# Merge la branche `staging` dans la branche `master`.
# CircleCI déploie automatiquement la branche `master` sur l'environnement de démo.
#
# Ce script n'est pas indispensable pour déployer sur l'environnement de démo ;
# il permet juste d'effectuer plusieurs vérification de sûreté avant de merger.

# Termine le script à la première commande en erreur
set -e
# Termine le script si une variable n'est pas définie
set -u

# Récupère le nom de la remote principale du projet (généralement 'origin' ou 'upstream')
function remote_name {
  git remote -v | grep "github.com.sgmap" | head -n 1 | cut -f 1
}

# Vérifie qu'aucun fichier n'est modifié sans être committé.
function assert_working_copy_clean {
  if [ $(git ls-files -cdmsu | wc -l) -ne 0 ]; then
    echo "Des fichiers ont été modifiés depuis le dernier commit."
    echo "Veuillez committer ou supprimer les modifications avant de déployer."
    git status -s
    exit 1
  fi
}

# Récupère les changements distants
function fetch_remote_changes {
  git fetch "$remote_name"
}

# Vérifie que la branche cible est bien à jour avec le dépôt distant
function assert_branch_up_to_date {
  local branch="$1"
  local commits_before=$(git rev-list "${remote_name}/${branch}..${branch}" | wc -l)
  if [ $commits_before -ne 0 ]; then
    echo "La branche locale '${branch}' n'est pas à jour avec '${remote_name}/${branch}'."
    echo "Mettez la branche '${branch}' à jour avant de continuer."
    exit 1
  fi
  local commits_after=$(git rev-list "${branch}..${remote_name}/${branch}" | wc -l)
  if [ $commits_after -ne 0 ] ; then
    echo "La branche locale '${branch}' n'est pas à jour avec '${remote_name}/${branch}'."
    echo "Mettez la branche '${branch}' à jour avant de continuer."
    exit 1
  fi
}

# Affiche les commits qui vont être mergé dans la branche cible
function print_changelog {
  echo "Les commits suivants vont être mergés dans '${target_branch}':"
  GIT_PAGER=cat git log --boundary --graph --oneline "${target_head}..${source_head}"
}

# Demande une confirmation avant d'effectuer le merge
function confirm_merge {
  read -p "Êtes-vous sûr de vouloir merger ces commits dans '${target_branch}' ? [o/N]" -n 1 -r
  echo
  if ! [[ $REPLY =~ ^[Oo]$ ]]; then
    exit 1
  fi
}

# Merge la branche source dans la branche cible, et publie les changements
function perform_merge {
  git checkout "$target_branch"
  git reset --hard "$target_head"
  git merge --no-edit "$source_branch"
  git push "$remote_name" "$target_branch:$target_branch"
  git checkout -

  echo
  echo "Les commits ont été mergées dans '${target_branch}'."
  echo "CircleCI va maintenant tester et déployer le commit sur l'environnement de démo."
  echo "Vous pouvez suivre la progression du déploiement sur https://circleci.com/gh/sgmap/mpal/tree/${target_branch}"
}

# Configuration des branches
source_branch="staging"
target_branch="master"
remote_name=$(remote_name)
source_head="$remote_name/$source_branch"
target_head="$remote_name/$target_branch"

# Exécution du script
assert_working_copy_clean
fetch_remote_changes
assert_branch_up_to_date "$source_branch"
assert_branch_up_to_date "$target_branch"
print_changelog
confirm_merge
perform_merge
