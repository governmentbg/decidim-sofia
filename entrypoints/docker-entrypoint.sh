#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

#eval `ssh-agent -s` && ssh-add /root/.ssh/id_rsa

bundle
bundle exec rails s -b 0.0.0.0