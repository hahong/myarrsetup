#!/bin/bash
# This script is meant to be called by cronjobmaster.sh
test "$PROJROOT" || PROJROOT=/home/array/array2/
test "$LOGDIR" || LOGDIR=$PROJROOT/utils/scheduled/log/
LOCK=$LOGDIR/01_getdata.sh.lock
CURRANIMAL=d005_Tito

###################################################################
# -- Get the data 

if [ -f $LOCK ]; then
	# -- if locked, terminates immediately
	echo "Locked:" $LOCK
	exit 1
fi
touch $LOCK

# 1. Tito
## -- NOT NEEDED ANYMORE
## ssh labuser@dicarlo3 'mv -b data/Tito*.txt data/blackrock_log/; mv -b data/Tito*.* data/blackrock_default/'   # move potentially dislocated files to collect repo dir
## ssh labuser@dicarlo4 'mv -b data/Tito*.txt data/blackrock_log/; mv -b data/Tito*.* data/blackrock_default/'   # move potentially dislocated files to collect repo dir
rsync -avzuH --exclude='/.snapshot' --remove-source-files labuser@dicarlo3:data/blackrock_default/Tito*.*   $PROJROOT/data/$CURRANIMAL/neudat_NSP1/ 2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_Tito_neudat_NSP1.log &
rsync -avzuH --exclude='/.snapshot' --remove-source-files labuser@dicarlo4:data/blackrock_default/Tito*.*   $PROJROOT/data/$CURRANIMAL/neudat_NSP2/ 2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_Tito_neudat_NSP2.log &
rsync -avzuH --exclude='/.snapshot' --remove-source-files labuser@dicarlo16:Documents/MWorks/Data/Tito*.mwk $PROJROOT/data/$CURRANIMAL/mwk/         2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_Tito_mwk.log &
wait

rsync -avzuH --exclude='/.snapshot' --remove-source-files labuser@dicarlo3:data/blackrock_log/Tito*.*       $PROJROOT/data/$CURRANIMAL/log_NSP1/    2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_Tito_log_NSP1.log &
rsync -avzuH --exclude='/.snapshot' --remove-source-files labuser@dicarlo4:data/blackrock_log/Tito*.*       $PROJROOT/data/$CURRANIMAL/log_NSP2/    2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_Tito_log_NSP2.log &
wait

rm -f $LOCK
