#!/bin/sh
# export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/var/run}
# export QT_QPA_PLATFORM=${QT_QPA_PLATFORM:-wayland}
mkdir /var
mkdir /var/run
chmod 0700 /var/run
export XDG_RUNTIME_DIR=/var/run
