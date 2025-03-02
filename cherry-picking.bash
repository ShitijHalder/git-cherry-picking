#!/bin/bash

LOG_FILE="script.log"
CONFLICTS=()

# Function to handle errors
handle_error() {
  echo "Error: $1" | tee -a "$LOG_FILE"
  exit 1
}

# Function to check if in a git repository
check_git_repository() {
  git rev-parse --is-inside-work-tree 2>/dev/null
  if [ $? -ne 0 ]; then
    handle_error "This script must be run inside a Git repository."
  fi
}

# Function to test input parameters
test_inputs() {
  local source_repo_url="$1"
  local target_repo_url="$2"
  local commit_list="$3"
  local source_branch="$4"
  local target_branch="$5"
  local git_user="$6"
  local git_token="$7"

  echo "Inside test_inputs function" | tee -a "$LOG_FILE"
  echo "Source Repo URL: $source_repo_url" | tee -a "$LOG_FILE"
  echo "Target Repo URL: $target_repo_url" | tee -a "$LOG_FILE"
  echo "Commit List: $commit_list" | tee -a "$LOG_FILE"
  echo "Source Branch: $source_branch" | tee -a "$LOG_FILE"
  echo "Target Branch: $target_branch" | tee -a "$LOG_FILE"
  echo "Git User: $git_user" | tee -a "$LOG_FILE"
  echo "Git Token: [REDACTED]" | tee -a "$LOG_FILE"

  echo "Token length: ${#git_token}" | tee -a "$LOG_FILE"

  git remote set-url origin "https://${git_user}:${git_token}@${target_repo_url#https://}" 2>&1 | tee -a "$LOG_FILE" || handle_error "Failed to set remote URL for target"

  echo "Remote URL set" | tee -a "$LOG_FILE"

  git fetch "$source_repo_url" "$source_branch" 2>&1 | tee -a "$LOG_FILE" || handle_error "Failed to fetch from source repository"
  echo "Fetched from source repository" | tee -a "$LOG_FILE"

  git fetch origin "$target_branch" 2>&1 | tee -a "$LOG_FILE" || handle_error "Failed to fetch from target repository"
  echo "Fetched from target repository" | tee -a "$LOG_FILE"

  git checkout "$target_branch" 2>&1 | tee -a "$LOG_FILE" || handle_error "Failed to checkout target branch"
  echo "Checked out target branch" | tee -a "$LOG_FILE"

  git remote add source "$source_repo_url" 2>&1 | tee -a "$LOG_FILE" || handle_error "Failed to add source remote"
  echo "Source remote added" | tee -a "$LOG_FILE"

  git fetch source "$source_branch" 2>&1 | tee -a "$LOG_FILE" || handle_error "Failed to fetch from source remote"
  echo "Fetched from source remote" | tee -a "$LOG_FILE"

  echo "Cherry-picking commits..." | tee -a "$LOG_FILE"
  IFS=',' read -ra COMMITS <<< "$commit_list"
  for commit in "${COMMITS[@]}"; do
    if [[ ${#commit} -lt 40 ]]; then
      handle_error "Commit hash $commit is not a full hash. Please use the full commit hash."
    fi

    # Stash local changes before cherry-picking
    git stash push -m "pre-cherry-pick stash" 2>&1 | tee -a "$LOG_FILE"

    git cherry-pick "$commit" 2>&1 | tee -a "$LOG_FILE"

    if [[ $? -ne 0 ]]; then
      echo "Encountered a conflict during cherry-pick for commit $commit" | tee -a "$LOG_FILE"
      CONFLICTS+=("$commit")

      for i in {5..1}; do
        echo "Conflict detected. Moving on to the next commit in $i seconds..." | tee -a "$LOG_FILE"
        sleep 1
      done

      git cherry-pick --abort 2>&1 | tee -a "$LOG_FILE"
      echo "Aborted cherry-pick for commit $commit" | tee -a "$LOG_FILE"
    fi

    # Pop the stashed changes after each cherry-pick
    git stash pop 2>&1 | tee -a "$LOG_FILE"
  done

  git push origin "$target_branch" 2>&1 | tee -a "$LOG_FILE" || handle_error "Failed to push changes"
  echo "Pushing changes to target branch" | tee -a "$LOG_FILE"

  git remote remove source 2>&1 | tee -a "$LOG_FILE"
  echo "Removing source remote" | tee -a "$LOG_FILE"

  if [[ ${#CONFLICTS[@]} -ne 0 ]]; then
    echo "The following commits encountered conflicts:" | tee -a "$LOG_FILE"
    for commit in "${CONFLICTS[@]}"; do
      echo "- $commit" | tee -a "$LOG_FILE"
    done
  fi
}

# Display the banner
echo "
............................................................
.  Cherry-Picking became easy!                              .
.                                                           .
.  Cherry-pick multiple commits at one time with no limits! .
.                                                           .
.  Before you start, keep in mind:                          .
.  - Ensure you are running the script inside the target    .
.    Git repo.                                              .
.  - Verify you have the correct username, permissions, and .
.    access tokens.                                         .
.  - Double-check your source and target branch names.      .
.  - Have a backup of your repository if necessary.         .
.                                                           .
.  Author: Shitij Halder ; Maintainer: Sayan Sarkar         .
.  Report issues on Telegram @shitijnotop or @sayann70      .
.                                                           .
.  Happy Cherry-Picking!                                    .
............................................................
"

echo "Reading input parameters..." | tee -a "$LOG_FILE"
read -e -p "Source repository URL: " SOURCE_REPO_URL
read -e -p "Target repository URL: " TARGET_REPO_URL
read -e -p "Source branch: " SOURCE_BRANCH
read -e -p "Target branch: " TARGET_BRANCH
read -e -p "Commit list (full hashes, comma-separated): " COMMIT_LIST
read -e -p "Git username: " GIT_USER
read -s -e -p "Git personal access token: " GIT_TOKEN

echo "Checking input parameters..." | tee -a "$LOG_FILE"
if [ -z "$SOURCE_REPO_URL" ]; then
  handle_error "Source repository URL is missing."
fi
if [ -z "$TARGET_REPO_URL" ]; then
  handle_error "Target repository URL is missing."
fi
if [ -z "$SOURCE_BRANCH" ]; then
  handle_error "Source branch is missing."
fi
if [ -z "$TARGET_BRANCH" ]; then
  handle_error "Target branch is missing."
fi
if [ -z "$COMMIT_LIST" ]; then
  handle_error "Commit list is missing."
fi
if [ -z "$GIT_USER" ]; then
  handle_error "Git username is missing."
fi
if [ -z "$GIT_TOKEN" ]; then
  handle_error "Git personal access token is missing."
fi

# Check if in a Git repository
check_git_repository

echo "Starting input test..." | tee -a "$LOG_FILE"
test_inputs "$SOURCE_REPO_URL" "$TARGET_REPO_URL" "$COMMIT_LIST" "$SOURCE_BRANCH" "$TARGET_BRANCH" "$GIT_USER" "$GIT_TOKEN"

echo "Your due cherry-picks are now done, my guy. Let us move on to the next task, shall we?" | tee -a "$LOG_FILE"
read -e -p "Press Enter to exit..."

exit 0
