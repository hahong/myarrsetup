#!/bin/bash
# This script is meant to be called by cronjobmaster.sh
test "$PROJROOT" || PROJROOT=/home/array/array/
test "$LOGDIR" || LOGDIR=$PROJROOT/analysis/scheduled/log/
LOCK=$LOGDIR/01_getdata.sh.lock

###################################################################
# -- Get the data 

if [ -f $LOCK ]; then
	# -- if locked, terminates immediately
	echo "Locked:" $LOCK
	exit 1
fi
touch $LOCK

# 1. Tito
ssh labuser@dicarlo3 'mv -b data/Tito*.txt data/blackrock_log/; mv -b data/Tito*.* data/blackrock_default/'   # move potentially dislocated files to collect repo dir
ssh labuser@dicarlo4 'mv -b data/Tito*.txt data/blackrock_log/; mv -b data/Tito*.* data/blackrock_default/'   # move potentially dislocated files to collect repo dir
rsync -avzuH --exclude='/.snapshot' --remove-source-files labuser@dicarlo3:data/blackrock_default/Tito*.* $PROJROOT/data/d004_Tito/neudat/ 2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_Tito_neudat.log &
rsync -avzuH --exclude='/.snapshot' --remove-source-files labuser@dicarlo4:data/blackrock_default/Tito*.* $PROJROOT/data/d004_Tito/neudat_NSP2/ 2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_Tito_neudat_dicarlo4.log &
rsync -avzuH --exclude='/.snapshot' --remove-source-files labuser@dicarlo16:Documents/MWorks/Data/Tito*.mwk $PROJROOT/data/d004_Tito/mwk/ 2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_Tito_mwk.log &
wait

rsync -avzuH --exclude='/.snapshot' --remove-source-files labuser@dicarlo3:data/blackrock_log/Tito*.* $PROJROOT/data/d004_Tito/log/ 2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_Tito_log.log &
rsync -avzuH --exclude='/.snapshot' --remove-source-files --ignore-existing labuser@dicarlo4:data/blackrock_log/Tito*.* $PROJROOT/data/d004_Tito/log/ 2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_Tito_log_dicarlo4.log &
wait

rm -f $LOCK
