#!/bin/bash
# This script is meant to be called by cronjobmaster.sh
test "$PROJROOT" || PROJROOT=/mindhive/dicarlolab/proj/array_data/array2/
test "$LOGDIR" || LOGDIR=$PROJROOT/utils/scheduled/log/
LCLBIN=$PROJROOT/utils/scheduled/
REMOTEFILER=dicarlo2
REMOTEUSER=array
REMOTEBIN=array2/utils/scheduled/
REMOTELOG=array2/utils/scheduled/log/
REMOTEDATA=array2/data/
LOCK=$LOGDIR/11_getdata.mh17.sh.lock
# these two are to support some manual manipulation of the rsync behavior
EXTOPTS1=$1
EXTOPTS2=$2

###################################################################
# if still processing the data at dicarlo2, then quits.
ssh $REMOTEUSER@$REMOTEFILER "test -f $REMOTELOG/01_getdata.sh.lock" && exit 1  
ssh $REMOTEUSER@$REMOTEFILER "test -f $REMOTELOG/02_analyze.sh.lock" && exit 1  

# -- Check lock
if [ -f $LOCK ]; then
        # -- if locked, terminates immediately
        echo "Locked:" $LOCK
        exit 1
fi
touch $LOCK

##################################################################
# Start fetch
LCLGET=$LCLBIN/12_getbadlist.mh17.sh
LCLSET=$LCLBIN/13_setbadlist.mh17.sh
RMTGET=$REMOTEBIN/12_getbadlist.mh17.sh
RMTSET=$REMOTEBIN/13_setbadlist.mh17.sh

LCLBADLST=$LOGDIR/12_getbadlist.mh17.sh.badlist
RMTBADLST=$REMOTELOG/12_getbadlist.mh17.sh.badlist

function syncall {
	rmtdir=`dirname $1`/`basename $1`/
	lcldir=`dirname $2`/`basename $2`/

	# syncbad: local -> remote
	$LCLGET $lcldir > $LCLBADLST
	scp $LCLBADLST $REMOTEUSER@$REMOTEFILER:$RMTBADLST 2>&1
	ssh $REMOTEUSER@$REMOTEFILER "$RMTSET $RMTBADLST $rmtdir; $RMTGET $rmtdir > $RMTBADLST" 
	# syncbad: remote -> local
	scp $REMOTEUSER@$REMOTEFILER:$RMTBADLST $LCLBADLST 2>&1
	$LCLSET $LCLBADLST $lcldir
	# file sync
	# -z is removed, as the line bandwidth is high enough; -K is added to follow/keep dir symlinks on the receiver (mh17)
	rsync -avuHK --exclude='*.ns5' --exclude='*.ns5.*' --exclude='.*ns5*' --exclude='.*nev*' --exclude='.*ccf*' --exclude='.*mwk*' --exclude='*cluster_wd*' $EXTOPTS1 $EXTOPTS2 $REMOTEUSER@$REMOTEFILER:$rmtdir $lcldir 2>&1
}

# -- 1. Tito
syncall $REMOTEDATA/d004_Tito/ $PROJROOT/data/d004_Tito/ | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_Tito_dicarlo2_d004_Tito.log
syncall $REMOTEDATA/d005_Tito/ $PROJROOT/data/d005_Tito/ | tee -a $LOGDIR/`date +%Y%m%d_%H%M%S`_Tito_dicarlo2_d005_Tito.log

echo $EXTOPTS1
echo $EXTOPTS2
 
# -- Done
rm -f $LOCK
