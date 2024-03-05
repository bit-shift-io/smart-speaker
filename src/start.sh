#!/usr/bin/env ash

# dbus
# https://gitlab.freedesktop.org/dbus/dbus/-/issues/441
ulimit -n 1024
dbus-daemon --system --fork

# apps
pipewire &
pipewire-pulse &

# extra
exec ash