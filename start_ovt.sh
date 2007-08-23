#!/bin/sh

# This script check the environment before lauching the server
$OVT_HOME=/home/kdeldycke/Desktop/svn

# Launch ruby cron-like server
ruby $OVT_HOME/script/backgroundrb stop
ruby $OVT_HOME/script/backgroundrb start

# Launch RoR server
ruby $OVT_HOME/script/server
