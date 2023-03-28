#!/bin/bash

set -euo pipefail

SUB_COMMAND=$1
VERSION=$2
CPU_ARCH="$(arch)"
CURRENT_PATH="$(cd $(dirname $0) && pwd)"
INSTALLATION_PATH="/mnt/efs/gretel"

function install() {
  if [ -z $VERSION ] ; then
    usage
    exit
  fi

  mkdir -p $INSTALLATION_PATH

  # Install JDK for Amazon Linux 2
  NEED_JAVA_16=`echo $VERSION | awk -F. '{if ( $1 > 1 || $2 >= 17) print "true"; else print "false";}'`
  NEED_JAVA_17=`echo $VERSION | awk -F. '{if ( $1 > 1 || $2 >= 18) print "true"; else print "false";}'`
  if [ $NEED_JAVA_17 = true ]; then
    # Amazon Corretto 16 (OpenJDK)
    sudo rpm --import https://yum.corretto.aws/corretto.key
    sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
    sudo yum install -y java-17-amazon-corretto-devel
  elif [ $NEED_JAVA_16 = true ]; then
    # Amazon Corretto 16 (OpenJDK)
    sudo rpm --import https://yum.corretto.aws/corretto.key
    sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
    sudo yum install -y java-16-amazon-corretto-devel
    sudo alternatives --set java /usr/lib/jvm/java-16-amazon-corretto/bin/java
  else
    # Amazon Corretto 8 (OpenJDK)
    sudo amazon-linux-extras enable corretto8
    sudo yum install -y java-1.8.0-amazon-corretto-devel
    sudo alternatives --set java /usr/lib/jvm/java-1.8.0-amazon-corretto.${CPU_ARCH}/jre/bin/java
  fi

  # Build spigot
  wget -O "$CURRENT_PATH/BuildTools.jar" "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
  java -jar "$CURRENT_PATH/BuildTools.jar" --rev "${VERSION}"
  mv "$CURRENT_PATH/spigot-$VERSION.jar" "$INSTALLATION_PATH/spigot-server.jar"

  # make symlinks to manage
  for FILE in $(ls -A './spigot'); do
    ln -sf "${CURRENT_PATH}/spigot/${FILE}" "${INSTALLATION_PATH}/${FILE}"
  done
  sudo ln -sf $CURRENT_PATH/systemd/hamal.service /etc/systemd/system/

  # run service
  sudo systemctl daemon-reload
  sudo systemctl enable hamal

  echo 'Success'
}

function update() {
    local NEED_UPGRADE_MARKER_DIR

    # Mark as need to --forceUpgrade
    NEED_UPGRADE_MARKER_DIR="${INSTALLATION_PATH}/tmp"
    mkdir -p "${NEED_UPGRADE_MARKER_DIR}"
    touch "${NEED_UPGRADE_MARKER_DIR}/need-upgrade"

    # then install
    install
}

function usage() {
  echo "$USAGE"
}

function main() {
    case $SUB_COMMAND in
      '-i'|'install')
        install
        ;;
      '-u'|'update')
        update
        ;;
      '-h'|'--help'|*)
        usage
        ;;
    esac
}

main $@
