 #!/bin/bash
DIR=/mnt/test
SYMDIR=/mnt/test/symlinks
LIBDIR=/mnt/test/plex

##############################
# Create Symlink Path        #
# if the path exist it will  #
# not create                 #
##############################

##############№########
## Symlinks Directory #
#######################

if [ ! -d "$SYMDIR" ]; then
    mkdir -p "$SYMDIR" && mkdir -p "$SYMDIR/sonarr" && mkdir -p "$SYMDIR/radarr"
    echo "Directory $SYMDIR created."
    echo "Directory $SYMDIR/sonarr created."
    echo "Directory $SYMDIR/radarr created."
else
    echo "Directory $SYMDIR already exists."
fi
##################
# Plex Directory #
##################
if [ ! -d "$LIBDIR" ]; then
    mkdir -p "$LIBDIR" && mkdir -p "$LIBDIR/Movies" && mkdir -p "$LIBDIR/Shows"
    echo "Directory $LIBDIR created."
    echo "Directory $LIBDIR/Movies created."
    echo "Directory $LIBDIR/Shows created."
else
    echo "Directory $LIBDIR already exists."
fi
