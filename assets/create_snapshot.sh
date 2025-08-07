#!/bin/bash

# This script updates the apt-mirror and creates a snapshot of the repositories.
# It prepares the snapshot directory structure and copies the contents of the mirror to the snapshot.
# The snapshot is timestamped and a symlink to the latest snapshot is created.
# Usage: ./update_mirror.sh
# The script assumes that the apt-mirror is already configured and the necessary directories exist.   

set -e
set -x
# Set the base path
BASE_PATH="/var/spool/apt-mirror"
MIRROR_SRC_PATH="$BASE_PATH/mirror"
SNAPSHOT_PATH="$BASE_PATH/snapshot"
TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)

# List of target repos names
TARGET_REPOS=("debian" "debian-security")

# List of subdirectories of each repo
SUB_DIRS=("dists" "pool")

prepare_snapshot() {
    echo "Preparing snapshot directory..."
    for target in "${TARGET_REPOS[@]}"; do
        for sub_dir in "${SUB_DIRS[@]}"; do
            mkdir -p "$SNAPSHOT_PATH/$target/$TIMESTAMP/$sub_dir"
        done
    done
}

create_snapshot() {
    # Loop through each immediate subdirectory under the base path
    for base_src in "$MIRROR_SRC_PATH"/*/; do
        [ -d "$base_src" ] || continue

        for target in "${TARGET_REPOS[@]}"; do
            if [ -d "$base_src$target" ]; then
                for sub_dir in "${SUB_DIRS[@]}"; do
                    cp -al "$base_src$target/$sub_dir/"* "$SNAPSHOT_PATH/$target/$TIMESTAMP/$sub_dir/"
                done
            fi
        done
    done
    ln -sf "$SNAPSHOT_PATH/$target/$TIMESTAMP" "$SNAPSHOT_PATH/$target/latest"
}

update_mirror() {
    echo "Updating mirror..."
    apt-mirror
    if [ $? -ne 0 ]; then
        echo "Error updating mirror. Exiting."
        exit 1
    fi
    prepare_snapshot
    create_snapshot
    echo "Mirror updated successfully."
}

main () {
    if [ ! -d "$MIRROR_SRC_PATH" ]; then
        echo "Mirror source path does not exist: $MIRROR_SRC_PATH"
        exit 1
    fi

    update_mirror
}
main "$@"


