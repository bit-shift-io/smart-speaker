#!/usr/bin/env ash

#export DBUS_SESSION_BUS_ADDRESS=`dbus-daemon --fork --config-file=/usr/share/dbus-1/session.conf --print-address`

# startup 01_envs.sh
export DISABLE_RTKIT=y
export XDG_RUNTIME_DIR=/tmp
export PIPEWIRE_RUNTIME_DIR=/tmp
export PULSE_RUNTIME_DIR=/tmp
export DISPLAY=:0.0

# to try:
#export $(dbus-launch)
#/usr/libexec/pipewire-launcher

# startup/10_dbus.sh
mkdir -p /var/run/dbus
# https://gitlab.freedesktop.org/dbus/dbus/-/issues/441
ulimit -n 1024
dbus-daemon --system --fork

# startup/20_xvfb.sh
#Xvfb -screen $DISPLAY 1920x1080x24 &

# startup/30_pipewire.sh
#mkdir -p /dev/snd
pipewire &
pipewire-pulse &

exec ash