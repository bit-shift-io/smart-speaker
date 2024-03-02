################################################################################
# smart speaker
#
# docker build -t bitshift/smart-speaker .
################################################################################


FROM alpine:latest
MAINTAINER Bronson

# Create a group and user
#RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Tell docker that all future commands should run as the appuser user
#USER appuser

#WORKDIR /

# needed for pipewire
#ENV XDG_RUNTIME_DIR='/tmp'

#VOLUME ["/var/run/dbus"]


# install pipewire to get audio to host
RUN apk add \
    pipewire \
    pipewire-tools \
    pipewire-alsa \
    pipewire-zeroconf \
    alsa-utils \
    wireplumber \
    bluez \
    pipewire-spa-bluez \
    bluez-openrc \
    dbus \
    openrc \
    pulseaudio-utils \
    pipewire-pulse \
    pulseaudio-utils \
    avahi
    

#     dbus-x11 rtkit

# enable services
#RUN rc-update add dbus
RUN rc-update add bluetooth

# copy configs
#COPY speaker-agent.py /
#COPY speaker-agent.service /etc/systemd/

# disable dbus in pipewire
RUN cp -a /usr/share/pipewire /etc
RUN cp -a /usr/share/wireplumber /etc
RUN sed -i 's/#support.dbus = true/support.dbus = false/' /etc/pipewire/pipewire.conf
RUN sed -i 's/#support.dbus = true/support.dbus = false/' /etc/wireplumber/wireplumber.conf
RUN sed -i 's/["with-logind"] = true,/["with-logind"] = false,/' /etc/wireplumber/bluetooth.lua.d/50-bluez-config.lua
RUN sed -i 's/["alsa.reserve"] = true,/["alsa.reserve"] = false,/' /etc/wireplumber/main.lua.d/50-alsa-config.lua
RUN sed -i 's/["enable-flatpak-portal"] = true,/["enable-flatpak-portal"] = false,/' /etc/wireplumber/main.lua.d/50-default-access-config.lua

# disable dbus in wireplumber
COPY ./src/80-disable-logind.lua /etc/wireplumber/bluetooth.lua.d/80-disable-logind.lua
COPY ./src/80-disable-dbus.lua /etc/wireplumber/main.lua.d/80-disable-dbus.lua

# enable audio server
COPY ./src/50-network-party.conf /etc/pipewire/pipewire-pulse.conf.d/50-network-party.conf

# bluetooth config
RUN sed -i 's/#JustWorksRepairing.*/JustWorksRepairing = always/' /etc/bluetooth/main.conf

# open ports
EXPOSE 4713
EXPOSE 5353

# dbus
COPY ./src/start.sh /usr/local/bin
RUN chmod +x /usr/local/bin/start.sh
CMD ["/bin/ash", "/usr/local/bin/start.sh"]
#ENTRYPOINT ["/bin/ash", "/usr/local/bin/start.sh"]
#ENTRYPOINT ["/bin/ash"]
#CMD ["/bin/ash"]

#CMD ["avahi"]
#CMD ["pipewire"]
#CMD ["pipewire-pulse"]
#CMD ["ash"]