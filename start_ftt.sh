#!/bin/sh

# This script check the environment before lauching the server
$FTT_HOME=~/ftt

# Launch ruby cron-like server
ruby $FTT_HOME/script/backgroundrb stop
ruby $FTT_HOME/script/backgroundrb start

# Launch RoR server
ruby $FTT_HOME/script/server
