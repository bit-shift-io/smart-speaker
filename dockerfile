################################################################################
# smart speaker
#
# docker build -t bitshift/smart-speaker .
################################################################################


FROM alpine:latest
MAINTAINER bitshift


# apps
RUN apk add \
    pipewire \
    pipewire-tools \
    pipewire-alsa \
    pipewire-zeroconf \
    alsa-utils \
    wireplumber \
    bluez bluez-openrc \
    pipewire-spa-bluez \
    dbus dbus-x11 \
    openrc \
    pulseaudio-utils \
    pipewire-pulse \
    pulseaudio-utils \
    pulseaudio \
    avahi \
    rtkit
    

# user/groups
ARG UID=1000
ARG GID=1000
ARG UNAME=bitshift
RUN addgroup -g $GID -S $UNAME
RUN adduser -S $UNAME -G $UNAME -u $UID
RUN addgroup $UNAME audio
RUN addgroup $UNAME rtkit
RUN addgroup $UNAME pipewire

#WORKDIR /



# services
#RUN rc-update add dbus
RUN rc-update add bluetooth



# configs
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

# startup script
COPY ./src/start.sh /usr/local/bin
RUN chmod +x /usr/local/bin/start.sh


# make dirs
RUN mkdir -p /run/user/1000
RUN chown -R $UID:$GID /run/user/1000

RUN mkdir -p /tmp
RUN chown -R $UID:$GID /tmp

RUN mkdir -p /var/run/dbus
RUN chown -R $UID:$GID /var/run/dbus


# env
ENV XDG_RUNTIME_DIR='/run/user/1000'
ENV DISABLE_RTKIT='y'
ENV PIPEWIRE_RUNTIME_DIR='/tmp'
ENV PULSE_RUNTIME_DIR='/tmp'
ENV DISPLAY=':0.0'

# open ports
EXPOSE 4713
EXPOSE 5353

# user
USER $UNAME

# commands
ENTRYPOINT ["/bin/ash", "/usr/local/bin/start.sh"]