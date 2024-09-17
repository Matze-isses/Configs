#!/bin/bash


case "$1" in
    commit)
        # Change to the parent directory containing the repositories
        git add .
        git commit -m "$2"
        if [ "/home/admin" = "$dir" ]; then
            exit 1
        fi

        # Iterate over all subdirectories
        for dir in */; do
            # Enter each subdirectory
            if [ -d "$dir/.git" ]; then
                echo "Committing changes in $dir"
                cd "$dir"
                
                # Check if there are any changes to commit
                if [ -n "$(git status --porcelain)" ]; then
                    echo "Committing changes in $dir"
                    git add .
                    git commit -m "$2"
                else
                    echo "No changes to commit in $dir"
                fi

                # Return to the parent directory
                cd ..
            fi
        done
        ;;
    push)
        # Iterate over all subdirectories
        for dir in */; do
            # Enter each subdirectory
            if [ -d "$dir/.git" ]; then
                echo "Committing changes in $dir"
                cd "$dir"
                
                # Check if there are any changes to commit
                if [ -n "$(git status --porcelain)" ]; then
                    echo "Committing changes in $dir"
                    git push
                else
                echo "No changes to commit in $dir"
                fi

                # Return to the parent directory
                cd ..
            fi
        done
        ;;
    *)
        ;;
esac

