#!/bin/bash
# This script is meant to be called by cronjobmaster.sh
test "$PROJROOT" || PROJROOT=/home/array/array2/
test "$LOGDIR" || LOGDIR=$PROJROOT/utils/scheduled/log/
LOCK=$LOGDIR/01_getdata.sh.lock

HOST_NSP1=dicarlo3
HOST_NSP2=dicarlo4
HOST_MWK=dicarlo16

###################################################################
# -- Get the data 

if [ -f $LOCK ]; then
	# -- if locked, terminates immediately
	echo "Locked:" $LOCK
	exit 1
fi
touch $LOCK

function getall {
	animal=$1
	dst=$2

	# NOT NEEDED ANYMORE:
	# ssh labuser@dicarlo3 'mv -b data/Tito*.txt data/blackrock_log/; mv -b data/Tito*.* data/blackrock_default/'   # move potentially dislocated files to collect repo dir
	# ssh labuser@dicarlo4 'mv -b data/Tito*.txt data/blackrock_log/; mv -b data/Tito*.* data/blackrock_default/'   # move potentially dislocated files to collect repo dir
	rsync -avuH --exclude='/.snapshot' --remove-source-files labuser@$HOST_NSP1:data/blackrock_default/${animal}*.*  $PROJROOT/data/$dst/neudat_NSP1/ 2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_${animal}_neudat_NSP1.log &
	rsync -avuH --exclude='/.snapshot' --remove-source-files labuser@$HOST_NSP2:data/blackrock_default/${animal}*.*  $PROJROOT/data/$dst/neudat_NSP2/ 2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_${animal}_neudat_NSP2.log &
	rsync -avuH --exclude='/.snapshot' --remove-source-files labuser@$HOST_MWK:Documents/MWorks/Data/${animal}*.mwk  $PROJROOT/data/$dst/mwk/         2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_${animal}_mwk.log &
	wait

	# do not use "&" to avoid overwritting
	rsync -avuH --exclude='/.snapshot' --remove-source-files                         labuser@$HOST_NSP1:data/blackrock_log/${animal}*.* $PROJROOT/data/$dst/log/ 2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_${animal}_log_NSP1.log
	rsync -avuH --exclude='/.snapshot' --remove-source-files --backup --suffix=.NSP2 labuser@$HOST_NSP2:data/blackrock_log/${animal}*.* $PROJROOT/data/$dst/log/ 2>&1 | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_${animal}_log_NSP2.log
}

# -- 1. Tito
#getall Tito d003_Tito 
#getall Tito d004_Tito 
getall Tito d005_Tito 

rm -f $LOCK
