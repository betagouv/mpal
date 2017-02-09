#!/bin/bash
# Merge la branche `dev` dans la branche `master`.
# CircleCI déploie automatiquement la branche `master` sur l'environnement de démo.

# Termine le script à la première commande en erreur
set -e

# Récupère le nom de la remote principale du projet (généralement 'origin' ou 'upstream')
function _remote_name {
  git remote -v | grep "github.com.sgmap" | head -n 1 | cut -f 1
}

# Vérifie qu'aucun fichier n'est modifié sans être committé.
function _assert_working_copy_clean {
  if [ $(git ls-files -cdmsu | wc -l) -ne 0 ]; then
    echo "Des fichiers ont été modifiés depuis le dernier commit."
    echo "Veuillez committer ou supprimer les modifications avant de déployer."
    git status -s
    exit 1
  fi
}

# Récupère les changements distants
function _fetch_remote_changes {
  git fetch "$remote_name"
}

# Vérifie que la branche cible est bien à jour avec le dépôt distant
function _assert_branch_up_to_date {
  local branch="$1"
  local commits_before=$(git rev-list "${remote_name}/${branch}..${branch}" | wc -l)
  if [ $commits_before -ne 0 ]; then
    echo "La branche locale '${branch}' n'est pas à jour avec '${remote_name}/${branch}':"
    GIT_PAGER=cat git log --boundary --graph --oneline "${remote_name}/${branch}..${branch}"
    echo "Mettez la branche à jour avant de continuer."
    exit 1
  fi
  local commits_after=$(git rev-list "${branch}..${remote_name}/${branch}" | wc -l)
  if [ $commits_after -ne 0 ] ; then
    echo "La branche locale '${branch}' n'est pas à jour avec '${remote_name}/${branch}':"
    GIT_PAGER=cat git log --boundary --graph --oneline "${branch}..${remote_name}/${branch}"
    echo "Mettez la branche à jour avant de continuer."
    exit 1
  fi
}

# Affiche les commits qui vont être mergé dans la branche cible
function _print_changelog {
  echo "Les commits suivants vont être mergés dans '${target_branch}':"
  GIT_PAGER=cat git log --boundary --graph --oneline "${target_head}..${source_head}"
}

# Demande une confirmation avant d'effectuer le merge
function _confirm_merge {
  read -p "Êtes-vous sûr de vouloir merger ces commits dans '${target_branch}' ? [o/N]" -n 1 -r
  echo
  if ! [[ $REPLY =~ ^[Oo]$ ]]; then
    exit 1
  fi
}

# Merge la branche source dans la branche cible, et publie les changements
function _perform_merge {
  git checkout "$target_branch"
  git reset --hard "$target_head"
  git merge --no-edit "$source_branch"
  git push "$remote_name" "$target_branch"
  git checkout -

  echo
  echo "Les commits ont été mergées dans '${target_branch}'."
  echo "CircleCI va maintenant tester et déployer le commit sur l'environnement de démo."
  echo "Vous pouvez suivre la progression du déploiement sur https://circleci.com/gh/sgmap/mpal/tree/${target_branch}"
}

# Configuration des branches
source_branch="dev"
target_branch="master"
remote_name=$(_remote_name)
target_head="$remote_name/master"

# Exécution du script
_assert_working_copy_clean
_fetch_remote_changes
_assert_branch_up_to_date "$source_branch"
_assert_branch_up_to_date "$target_branch"
_print_changelog
_confirm_merge
_perform_merge
