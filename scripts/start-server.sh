#!/bin/bash
export DISPLAY=:99
export XAUTHORITY=${DATA_DIR}/.Xauthority


if [ "${CUSTOM_RES_W}" -le 1279 ]; then
	echo "---Width to low must be a minimal of 1280 pixels, correcting to 1024...---"
    CUSTOM_RES_W=1280
fi
if [ "${CUSTOM_RES_H}" -le 1023 ]; then
	echo "---Height to low must be a minimal of 1024 pixels, correcting to 768...---"
    CUSTOM_RES_H=1024
fi

echo "---Checking for old display lock files---"
rm -rf /tmp/.X99*
rm -rf /tmp/.X11*
rm -rf ${DATA_DIR}/.vnc/*.log ${DATA_DIR}/.vnc/*.pid
chmod -R ${DATA_PERM} ${DATA_DIR}
if [ -f ${DATA_DIR}/.vnc/passwd ]; then
	chmod 600 ${DATA_DIR}/.vnc/passwd
fi
screen -wipe 2&>/dev/null

echo "---Starting TurboVNC server---"
vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :99 -rfbport ${RFB_PORT} -noxstartup ${TURBOVNC_PARAMS} 2>/dev/null
sleep 2
echo "---Starting Fluxbox---"
env HOME=/etc /usr/bin/fluxbox 2>/dev/null &
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
sleep 2

echo "---Container under construction!---"
sleep infinity

echo "---Starting MyCrypto---"
cd ${DATA_DIR}