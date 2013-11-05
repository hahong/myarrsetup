#!/bin/bash
# This script is meant to be called by cronjobmaster.sh
test "$PROJROOT" || PROJROOT=/home/array/array2/
test "$LOGDIR" || LOGDIR=$PROJROOT/utils/scheduled/log/
LOCK=$LOGDIR/02_analyze.sh.lock
LOGNAME=$LOGDIR/`date +%Y%m%d_%H%M%S`_analysis.log
HTMLPSTH=/home/array/public_html/psth/
EXTOPTS=$1
NJOBSDEF=4

###################################################################
if [ -f $LOCK ]; then
	# -- if locked, terminates immediately
	echo "Locked:" $LOCK
	exit 1
fi
touch $LOCK   # create a lock file so that no data transfer occurs from mh17

function procall {
	bdir=$1      # basedir
	pdfhome=$2   # pdf destination in the dataset
	test "$pdfhome" || pdfhome=subproj/100_PSTH   # default pdfhome
	# merge
	jobname=joblist/`date +%Y%m%d_z0_merge_%H%M%S`.sh
	utils/mkjobs merge STDOUT $bdir/mwk $bdir/neudat_NSP1 $bdir/mwk_merged >> $jobname
	utils/mkjobs merge STDOUT $bdir/mwk $bdir/neudat_NSP2 $bdir/mwk_merged >> $jobname
	echo === Merge Begin ===
	NJOBS=$NJOBSDEF parrun.py $jobname 2>&1
	echo === Merge End ===
	echo
	
	# collect psf
	jobname=joblist/`date +%Y%m%d_z1_psf_%H%M%S`.sh
	utils/mkjobs psf STDOUT $bdir/mwk_merged $bdir/data_postproc >> $jobname
	echo === Merge Begin ===
	NJOBS=$NJOBSDEF parrun.py $jobname 2>&1
	echo === Merge End ===
	echo
	
	# feature comp
	jobname=joblist/`date +%Y%m%d_z2_feat_%H%M%S`.sh
	utils/mkjobs feat STDOUT $bdir/data_postproc $bdir/data_postproc >> $jobname
	echo === Merge Begin ===
	NJOBS=$NJOBSDEF parrun.py $jobname 2>&1
	echo === Merge End ===
	echo
	
	# plot psths
	jobname=joblist/`date +%Y%m%d_z9_feat_%H%M%S`.sh
	utils/mkjobs plotpsth STDOUT $bdir/data_postproc $bdir/$pdfhome >> $jobname
	echo === PSTHs Begin ===
	NJOBS=$NJOBSDEF parrun.py $jobname 2>&1
	rsync -a $bdir/$pdfhome/*.pdf $HTMLPSTH 2>&1
	echo === PSTHs End ===
	echo

	sleep 2  # to ensure separate job files
}

# -- Process and analyze all the following active datasets
cd $PROJROOT/
procall data/d004_Tito | tee -a $LOGNAME 
#procall data/d005_Tito | tee -a $LOGNAME 

# -- END
rm -f $LOCK
