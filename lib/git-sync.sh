#!/usr/bin/env bash
# Not tested with non-bash shell

# Git might hang if cloning or pulling requires authentication.
# Always schedule with a timeout.

set -e

# Directory to keep in sync with remote
dir=$1
if [[ -z "$dir" ]]
then
  echo "${GIT_SYNC_DIR_MESSAGE:-Pass directory as first argument}"
  exit 1
fi

# Repository to clone from in case the local repo isn't initialized.
# Don't try to initialize repo if this is the empty string.
cloneFrom=$2



if [[ -d "${dir%/}/.git" ]]
then
  # Always just pull if repo is already present.
  # We don't bother checking that the present repo matches $cloneFrom.
  git -C "$dir" pull --ff-only

elif [[ -n "$cloneFrom" ]]
then
  # We try to clone into $dir. git clone handles creating it if it doesn't exist
  # and checking that it is empty.
  git clone "$cloneFrom" "$dir"

else
  local msg="No git repository at $dir. Specify a git repo as the second argument to clone it."
  echo "${GIT_SYNC_CLONE_MESSAGE:-$msg}"
fi
