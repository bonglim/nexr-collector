#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if [ $# -le 0 ]; then
  echo "Usage: collect-agent.sh (start|stop|run) "
  exit 1
fi

actionCmd=$1
shift

this="${BASH_SOURCE-$0}"

BASEDIR=`dirname ${this}`
BASEDIR=`cd ${BASEDIR}/..;pwd`

COLLECTOR_HOME=$BASEDIR
source ${COLLECTOR_HOME}/bin/collector-env.sh

if [ "$CONF_HOME" == "" ]; then
    CONF_HOME=$COLLECTOR_HOME
fi
UPLOADER_CONF_HOME=$CONF_HOME/uploader
CONF_FILE=$UPLOADER_CONF_HOME/uploader.conf

if [ "$LOG_DIR" == "" ]; then
    LOG_DIR=${COLLECTOR_HOME}/logs
fi

if [ "$GANGLIA_HOST" != "" ]; then
    MONITOR="-Dflume.monitoring.type=ganglia -Dflume.monitoring.hosts=${GANGLIA_HOST}"
fi

AGENT_NAME=agent

if [ "$UPLOADER_PID_DIR" = "" ]; then
  UPLOADER_PID_DIR=/tmp
fi
log=$UPLOADER_PID_DIR/uploader.out
pid=$UPLOADER_PID_DIR/uploader.pid
STOP_TIMEOUT=${STOP_TIMEOUT:-3}

case $actionCmd in

  (start)
    [ -w "$UPLOADER_PID_DIR" ] ||  mkdir -p "$UPLOADER_PID_DIR"

    if [ -f $pid ]; then
      if kill -0 `cat $pid` > /dev/null 2>&1; then
        echo $command running as process `cat $pid`.  Stop it first.
        exit 1
      fi
    fi

    echo starting $command logging to $log
    $FLUME_HOME/bin/flume-ng agent --conf $UPLOADER_CONF_HOME --conf-file $CONF_FILE -n $AGENT_NAME -Dlog.dir=${LOG_DIR} $MONITOR > "$log" 2>&1 </dev/null &

    echo $! > $pid
    TARGET_PID=`cat $pid`
    echo starting as process $TARGET_PID
    ;;
  (stop)

    if [ -f $pid ]; then
      TARGET_PID=`cat $pid`
      if kill -0 $TARGET_PID > /dev/null 2>&1; then
        echo stopping $command
        kill $TARGET_PID
        sleep $STOP_TIMEOUT
        if kill -0 $TARGET_PID > /dev/null 2>&1; then
          echo "$command did not stop gracefully after $STOP_TIMEOUT seconds: killing with kill -9"
          kill -9 $TARGET_PID
        fi
      else
        echo no $command to stop
      fi
      rm -f $pid
    else
      echo no $command to stop
    fi
    ;;

  (*)
    echo $usage
    exit 1
    ;;

esac


