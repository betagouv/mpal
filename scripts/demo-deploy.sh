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

# Vérifie que la branche cible est bien à jour avec le dépôt distant
function _assert_target_up_to_date {
  git fetch "$remote_name"
  local diverged_target_commits=$(git rev-list "${target_head}..${target_branch}" | wc -l)
  if [ $diverged_target_commits -ne 0 ]; then
    echo "Local branch '${target_branch}' is not up-to-date with '${target_head}':"
    git log --boundary --graph --oneline "${target_head}..${target_branch}"
    echo "Aborting..."
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
  git merge --no-edit --no-ff "$source_branch"
  git push "$remote_name" "$target_branch"
  git checkout -

  echo "Les commits ont été mergées dans '${target_branch}'."
  echo "CircleCI va maintenant tester et déployer '${target_branch}' sur l'environnement de démo."
  echo "Vous pouvez suivre la progression du déploiement sur https://circleci.com/gh/sgmap/mpal/tree/${target_branch}"
}

# Configuration des branches
source_branch="dev"
target_branch="master"
remote_name=$(_remote_name)
target_head="$remote_name/master"

# Exécution du script
_assert_working_copy_clean
_assert_target_up_to_date
_print_changelog
_confirm_merge
_perform_merge
