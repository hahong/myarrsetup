#!/bin/bash
test "$HOME" || HOME=/home/array/
export PROJROOT=$HOME/array2/
export CRONDIR=$PROJROOT/utils/scheduled/
export LOGDIR=$CRONDIR/log/

. $HOME/.profile 
$CRONDIR/01_getdata.sh && $CRONDIR/02_analyze.sh
