#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Usage fluentd_install_remote.sh <full_log_file_path> <host:port>"
    exit 1
fi

IFS=':' read HOST PORT <<< $2

if [ -z "$HOST" ] || [ -z "$PORT" ]; then
    echo "Invalid host" $2
    exit 1
fi 

if [ ! -f $1 ]; then
    echo $1 "is not found!"
    exit 1
fi 
if ! type "fluentd" 1> /dev/null 2> /dev/null; then
  echo "Installing fluentd"
  sudo apt-get update; apt-get install -y ruby ruby-dev gcc make netcat
  gem install fluentd -v "0.14.19"
fi
nc -z $HOST $PORT
if [ $? ]; then
    echo "WARNING! Failed to connect to" $2
fi

mkdir -p /usr/local/fluentd/conf
echo "<source>
   type tail
  path "$1"
  format none
  pos_file /tmp/fluentd-1111111111.pos
  tag tail
  read_from_head true
  refresh_interval 5
</source>

<match **>
  @type forward
  flush_interval 1s
  <server>
    host" $HOST"
    port" $PORT"
  </server>
</match>" > /usr/local/fluentd/conf/remote.conf

echo "To start connector run fluentd -c /usr/local/fluentd/conf/remote.conf"