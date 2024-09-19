reset_branch() {
    git checkout "$1"
    git fetch
    git reset --hard
    git clean -x -d -f
}

# Clone the PrusaSlicer repository if it doesn't exist, otherwise reset it
if [ ! -d "$AUTOSETUP_TARGET_DIR" ]; then
    git clone "$AUTOSETUP_FORK_REPO_URL" "$AUTOSETUP_TARGET_DIR"
else
    cd "$AUTOSETUP_TARGET_DIR"
    reset_branch "$AUTOSETUP_FORK_BASE_BRANCH"
    # for each branch in the list, reset it
    for branch in $AUTOSETUP_FEATURE_BRANCH_STACK; do
        reset_branch "$branch"
    done
fi

cd "$AUTOSETUP_TARGET_DIR"

# Sync with upstream
git remote add autosetup_upstream "$AUTOSETUP_UPSTREAM_REPO_URL" || true
git fetch autosetup_upstream
git checkout "$AUTOSETUP_FORK_BASE_BRANCH"
git rebase autosetup_upstream/$AUTOSETUP_UPSTREAM_BASE_BRANCH

# Rebase feature branches on top of master
base_branch="$AUTOSETUP_FORK_BASE_BRANCH"
for branch in $AUTOSETUP_FEATURE_BRANCH_STACK; do
    git checkout "$branch"
    git rebase "$base_branch"
    base_branch="$branch"
done