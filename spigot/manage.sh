#!/bin/bash
set -e

SUB_COMMAND=$1
SCREEN_NAME=hamal
SERVER_PATH="/mnt/efs/gretel"

start() {
  local SPIGOT_ARGS NEED_UPGRADE_MARKER_FILE MEM_CAPS

  SPIGOT_ARGS="--nogui"

  # if needs world upgrade, specify --forceUpgrade
  NEED_UPGRADE_MARKER_FILE="${SERVER_PATH}/tmp/need-upgrade"
  if [[ -e ${NEED_UPGRADE_MARKER_FILE} ]]; then
      SPIGOT_ARGS="${SPIGOT_ARGS} --forceUpgrade"
      rm ${NEED_UPGRADE_MARKER_FILE}
  fi

  cd "${SERVER_PATH}"

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
  # stop if server process is live
  if screen -list | grep -q $SCREEN_NAME; then
    screen -S $SCREEN_NAME -X stuff "say メンテナンスです！あと10秒でサーバーが落ちます〜！\n"
    sleep 10
    screen -S $SCREEN_NAME -X stuff "save-all\n"
    screen -S $SCREEN_NAME -X stuff "stop\n"
  fi
}

case $SUB_COMMAND in
  'start')
    start
    ;;
  'stop')
    stop
    ;;
esac
