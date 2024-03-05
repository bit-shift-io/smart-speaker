#!/usr/bin/env ash

# env
export XDG_RUNTIME_DIR='/run/user/1000'
export DISABLE_RTKIT='y'
export PIPEWIRE_RUNTIME_DIR='/tmp'
export PULSE_RUNTIME_DIR='/tmp'
export DISPLAY=':0.0'
export PYTHONUNBUFFERED='1'

# dbus
# https://gitlab.freedesktop.org/dbus/dbus/-/issues/441
echo 'launching dbus...'
ulimit -n 1024
# /var/run/dbus/system_bus_socket
dbus-daemon --session --fork --print-address --address unix:path=/var/run/dbus/system_bus_socket
# --system --address unix:path=$XDG_RUNTIME_DIR/bus
# dbus-daemon --nofork --address unix:path=$XDG_RUNTIME_DIR/bus --session
#dbus-daemon --fork --address unix:path=$XDG_RUNTIME_DIR/bus --session
#dbus-daemon --nofork --address unix:path=$XDG_RUNTIME_DIR/bus --session

# apps --no-chroot  
avahi-daemon --no-drop-root --daemonize &
pipewire &
wireplumber &
pipewire-pulse &
#python /usr/local/bin/speaker-agent.py

# extra
exec ash