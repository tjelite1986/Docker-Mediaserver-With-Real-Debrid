 #!/bin/bash

    if [[ $# -lt 2 ]]; then 
        echo "usage: elfbot <command> <app> <optional>"
        echo
        echo '<app> must match an app found in /config'
        echo
        echo "valid commands are:"
        echo
        echo "elfbot blackhole <app>                        : symlink the contents of the CWD into /storage/symlinks/blackhole/<app>/ for automated import"
        echo "elfbot symlink <storage-mount>                : import remotely-mounted, read-only media as symlinks, or generate a report"
        echo "elfbot symlink report-broken                  : generate a report on all broken symlinks found under /storage/symlinks"
        echo "elfbot symlink delete-broken                  : delete (without confirmation!) all broken symlinks found under /storage/symlinks"
        echo "elfbot recyclarr <command>                    : run recyclarr (using config files in /storage/elfstorage/recyclarr)" 

        echo
    fi

    case $1 in
    "blackhole")

            if [[ "$#" -lt 2 ]]; then
                echo "ERROR: target missing - example : 'elfbot blackhole radarr'"
                exit 1
            fi
            ITEMPATH="$(pwd)"

            # Never symlink ourselves!
            if [[ $ITEMPATH == *"/storage/symlinks"* ]]; then
                echo "ERROR: Can't symlink a source in /storage/symlinks (#deathbysymlink)"
                exit 1
            fi

            # Get ready to create symlinks

            TARGET=/storage/symlinks/blackhole/$2
            CACHE=/storage/symlinks/blackhole/.symlink_cache

            echo "Symlinking new items in $ITEMPATH to $TARGET... "
            mkdir -p $TARGET
            mkdir -p $CACHE

            ls "${ITEMPATH}/" | while read -r ITEM
            do
                # symlink to target only if cache doesn't already exist
                # so that if a user moves a file out of the TARGET folder while importing, we don't recreate it
                ln -s "${ITEMPATH}/${ITEM}" "$CACHE/" 2> /dev/null
                if [[ $? -eq 0 ]]; then
                    cp -rs "${ITEMPATH}/${ITEM}" "$TARGET/" 2> /dev/null
                echo "[created symlink] $TARGET/${ITEM}"
                else
                echo "[already exists, skipped] $CACHE/${DIR}${ITEM}"
                fi
            done

            echo "Done! ??"

            ;;

        "symlink")

            if [[ "$#" -lt 2 ]]; then
                echo "ERROR: path missing - example : 'elfbot symlink /storage/realdebrid-zurg/movies'"
                exit 1
            elif [[ "$2" == "report-broken" ]]; then
                echo "Generating symlink report, see /symlinks/report.txt for details..."
                echo -e "Listing broken symlinks as identified at $(date)..\n\n" > /storage/symlinks/report.txt
                find /storage/elfstorage -xtype l | grep -v .symlinked_cache >> /storage/symlinks/report.txt
                find /storage/symlinks   -xtype l | grep -v .symlinked_cache >> /storage/symlinks/report.txt
                exit 0
            elif [[ "$2" == "delete-broken" ]]; then
                echo "Deleting all broken symlinks..."
                find /storage/symlinks -xtype l -exec rm {} \;
                find /storage/elfstorage -xtype l -exec rm {} \;
                echo ".. Done!"
                exit 0
            elif [[ "$2" == "here" ]]; then
                ITEMPATH="$(pwd)"
            elif [[ ! -d "$2" ]]; then
                echo "ERROR: $2 does not exist"
                exit 1
            else
                ITEMPATH=$2
            fi

            # Never symlink ourselves!
            if [[ $ITEMPATH == *"/storage/symlinks"* ]]; then
                echo "ERROR: Can't symlink a source in /storage/symlinks (#deathbysymlink)"
                exit 1
            fi

            # Get ready to create symlinks
            mkdir -p /storage/symlinks/.symlink_cache

            TARGET=/storage/symlinks/import
            CACHE=/storage/symlinks/.symlink_cache

            # Get the last bit of the source path
            DIR=$(awk -F'/' '{ a = length($NF) ? $NF : $(NF-1); print a }' <<< $ITEMPATH)
            echo "Symlinking new items in $ITEMPATH to $TARGET/${DIR}... "
            mkdir -p "$TARGET/${DIR}"
            mkdir -p "$CACHE/${DIR}"

            ls "${ITEMPATH}/" | while read -r ITEM
            do
                # symlink to target only if cache doesn't already exist
                # so that if a user moves a file out of the TARGET folder while importing, we don't recreate it
                ln -s "${ITEMPATH}/${ITEM}" "$CACHE/${DIR}/" 2> /dev/null
                if [[ $? -eq 0 ]]; then
                    cp -rs "${ITEMPATH}/${ITEM}" "$TARGET/${DIR}/" 2> /dev/null
                fi
            done

            echo "Done! ??"

            ;;
    esac
