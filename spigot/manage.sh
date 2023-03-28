#!/bin/bash
set -e

SUB_COMMAND=$1
SERVER_PATH="/mnt/efs/gretel"

start() {
  local SPIGOT_ARGS NEED_UPGRADE_MARKER_FILE SCREEN_NAME MEM_CAPS

  SPIGOT_ARGS="--nogui"

  # if needs world upgrade, specify --forceUpgrade
  NEED_UPGRADE_MARKER_FILE="${SERVER_PATH}/tmp/need-upgrade"
  if [[ -e ${NEED_UPGRADE_MARKER_FILE} ]]; then
      SPIGOT_ARGS="${SPIGOT_ARGS} --forceUpgrade"
      rm ${NEED_UPGRADE_MARKER_FILE}
  fi

  cd "${SERVER_PATH}"
  SCREEN_NAME=spigot

  # run server in screen
  # optimal memory caps:
  #   c6g.xlarge : 6000M
  #   c6g.large : 3000M
  MEM_CAPS=3000M
  screen -AdmS $SCREEN_NAME java -Xms${MEM_CAPS} -Xmx${MEM_CAPS} -jar "${SERVER_PATH}/spigot-server.jar" $SPIGOT_ARGS

  # wait for exit
  while screen -list | grep -q $SCREEN_NAME; do
    sleep 1
  done
}

stop() {
  screen -S spigot -X stuff "say メンテナンスです！あと10秒でサーバーが落ちます〜！\n"
  sleep 10
  screen -S spigot -X stuff "save-all\n"
  screen -S spigot -X stuff "stop\n"
}

case $SUB_COMMAND in
  'start')
    start
    ;;
  'stop')
    stop
    ;;
esac
