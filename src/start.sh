#!/usr/bin/env ash

#export DISABLE_RTKIT=y
#export XDG_RUNTIME_DIR=/tmp
#export PIPEWIRE_RUNTIME_DIR=/tmp
#export PULSE_RUNTIME_DIR=/tmp
#export DISPLAY=:0.0

# dbus
mkdir -p /var/run/dbus
# https://gitlab.freedesktop.org/dbus/dbus/-/issues/441
ulimit -n 1024
#dbus-daemon --system --fork

# to try:
export $(dbus-launch)
/usr/libexec/pipewire-launcher


# apps
pipewire &
pipewire-pulse &

# extra
exec ash