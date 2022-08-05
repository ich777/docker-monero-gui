FROM ich777/novnc-baseimage

LABEL org.opencontainers.image.authors="admin@minenet.at"
#LABEL org.opencontainers.image.source="https://github.com/ich777/docker-monero-gui"

RUN export TZ=Europe/Rome && \
	apt-get update && \
	apt-get -y install --no-install-recommends jq bzip2 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0-dev libxcb-render-util0 libxcb-shape0 libxcb-xkb1 libxkbcommon-x11-0 && \
    sed -i '/    document.title =/c\    document.title = "MoneroGUI - noVNC";' /usr/share/novnc/app/ui.js && \
	rm /usr/share/novnc/app/images/icons/*

ENV DATA_DIR=/monero
ENV CUSTOM_RES_W=1024
ENV CUSTOM_RES_H=768
ENV CUSTOM_DEPTH=16
ENV NOVNC_PORT=8080
ENV RFB_PORT=5900
ENV TURBOVNC_PARAMS="-securitytypes none"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="monero"

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
#COPY /icons/* /usr/share/novnc/app/images/icons/
COPY /conf/ /etc/.fluxbox/
RUN chmod -R 770 /opt/scripts/

EXPOSE 8080

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]