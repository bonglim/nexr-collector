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
  echo "Usage: agents.sh (start|stop|restart) "
  exit 1
fi

actionCmd=$1
shift

this="${BASH_SOURCE-$0}"

BASEDIR=`dirname ${this}`
BASEDIR=`cd ${BASEDIR}/..;pwd`

COLLECTOR_HOME=$BASEDIR
echo COLLECTOR_HOME $COLLECTOR_HOME

STOP_TIMEOUT=${STOP_TIMEOUT:-10}

case $actionCmd in

  (start)
    $COLLECTOR_HOME/bin/umonitor.sh start
    sleep $STOP_TIMEOUT
    $COLLECTOR_HOME/bin/uploader.sh start
    ;;
  (stop)
    $COLLECTOR_HOME/bin/uploader.sh stop
    sleep $STOP_TIMEOUT
    $COLLECTOR_HOME/bin/umonitor.sh stop
    ;;
  (*)
    echo $usage
    exit 1
    ;;

esac


