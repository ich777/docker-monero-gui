#!/bin/bash
export DISPLAY=:0
export XAUTHORITY=${DATA_DIR}/.Xauthority

LAT_V="$(wget -qO- https://api.github.com/repos/monero-project/monero-gui/releases/latest | jq -r '.tag_name')"
CUR_V="$(find ${DATA_DIR}/bin -maxdepth 1 -type f -name "monero-gui_*" 2>/dev/null | cut -d '_' -f2)"

if [ -z "${LAT_V}" ]; then
  if [ -z "${CUR_V}" ]; then
    echo "---Can't get latest version from Monero-GUI and found no local installed version!---"
	sleep infinity
  else
    echo "---Can't get latest version from Monero-GUI, falling back to installed version ${CUR_V}---"
	LAT_V="${CUR_V}"
  fi
fi

rm -rf ${DATA_DIR}/monero-gui*.tar.bz2

echo "---Version Check---"
if [ -z "${CUR_V}" ]; then
  echo "---Monero-GUI not installed, installing...---"
  cd ${DATA_DIR}
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/monero-gui_${LAT_V}.tar.bz2 "https://downloads.getmonero.org/gui/monero-gui-linux-x64-${LAT_V}.tar.bz2" ; then
    echo "---Sucessfully downloaded Monero-GUI---"
  else
    echo "---Something went wrong, can't download Monero-GUI, putting container in sleep mode---"
    sleep infinity
  fi
  mkdir -p ${DATA_DIR}/bin
  tar -C ${DATA_DIR}/bin --strip-components=1 -xvf ${DATA_DIR}/monero-gui_${LAT_V}.tar.bz2
  rm -rf ${DATA_DIR}/monero-gui_${LAT_V}.tar.bz2
  touch ${DATA_DIR}/bin/monero-gui_${LAT_V}
elif [ "${CUR_V}" != "${LAT_V}" ]; then
  echo "---Version missmatch, installed ${CUR_V}, downloading and installing latest ${LAT_V}...---"
  cd ${DATA_DIR}
  rm -rf ${DATA_DIR}/bin
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/monero-gui_${LAT_V}.tar.bz2 "https://downloads.getmonero.org/gui/monero-gui-linux-x64-${LAT_V}.tar.bz2" ; then
    echo "---Sucessfully downloaded Monero-GUI---"
  else
    echo "---Something went wrong, can't download Monero-GUI, putting container in sleep mode---"
    sleep infinity
  fi
  mkdir -p ${DATA_DIR}/bin
  tar -C ${DATA_DIR}/bin --strip-components=1 -xvf ${DATA_DIR}/monero-gui_${LAT_V}.tar.bz2
  rm -rf ${DATA_DIR}/monero-gui_${LAT_V}.tar.bz2
  touch ${DATA_DIR}/bin/monero-gui_${LAT_V}
elif [ "${CUR_V}" == "${LAT_V}" ]; then
	echo "---Monero-GUI $CUR_V up-to-date---"
fi

if [ "${CUSTOM_RES_W}" -le 1279 ]; then
	echo "---Width to low must be a minimal of 1280 pixels, correcting to 1024...---"
    CUSTOM_RES_W=1280
fi
if [ "${CUSTOM_RES_H}" -le 1023 ]; then
	echo "---Height to low must be a minimal of 1024 pixels, correcting to 768...---"
    CUSTOM_RES_H=1024
fi

echo "---Checking for old display lock files---"
rm -rf /tmp/.X0*
rm -rf /tmp/.X11*
rm -rf /tmp/xmr*
rm -rf ${DATA_DIR}/.vnc/*.log ${DATA_DIR}/.vnc/*.pid
chmod -R ${DATA_PERM} ${DATA_DIR}
if [ -f ${DATA_DIR}/.vnc/passwd ]; then
	chmod 600 ${DATA_DIR}/.vnc/passwd
fi
screen -wipe 2&>/dev/null

echo "---Starting TurboVNC server---"
vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :0 -rfbport ${RFB_PORT} -noxstartup ${TURBOVNC_PARAMS} 2>/dev/null
sleep 2
echo "---Starting Fluxbox---"
env HOME=/etc /usr/bin/fluxbox 2>/dev/null &
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
sleep 2

echo "---Starting Monero-GUI---"
cd ${DATA_DIR}
${DATA_DIR}/bin/monero-wallet-gui