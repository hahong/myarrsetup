#!/bin/bash
test "$HOME" || HOME=/mindhive/dicarlolab/u/hahong/
export PROJROOT=$HOME/teleport/array/array2/
export CRONDIR=$PROJROOT/utils/scheduled/
export LOGDIR=$CRONDIR/log/

. $HOME/.bash_profile
$CRONDIR/11_getdata.mh17.sh
