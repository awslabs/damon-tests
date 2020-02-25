#!/bin/bash

# exp: performance
# variance: (parsec3|splash2x)/<workload>/(orig|thp|ethp)
# $1: <...>/results/performance/(parsec3|splash2x)/<workload>/(orig|thp|ethp)/0(0-9)/

if [ $# -ne 1 ]
then
	echo "Usage: $0 <output dir>"
	exit 1
fi

ODIR=$1

PARSEC_RUN="$HOME/parsec3_on_ubuntu/run.sh"
DAMO="$HOME/linux/tools/damon/damo"
LBX="$HOME/lazybox"

EXP_DIR="$ODIR/../../../../../../performance/"
var=$(basename $(dirname $ODIR))
work=$(basename $(dirname $(dirname $ODIR)))
echo $work

if [ "$var" = "orig" ] || [ "$var" = "thp" ]
then
	if [ "$var" = "thp" ]
	then
		sudo $LBX/scripts/turn_thp.sh always
	else
		sudo $LBX/scripts/turn_thp.sh madvise
	fi

	$PARSEC_RUN $work | tee $ODIR/commlog
	exit
fi

# var == ethp
sudo $LBX/scripts/turn_thp.sh madvise
$PARSEC_RUN $work | tee $ODIR/commlog &
if [ "$work" = "raytrace" ]
then
	work="rtview"
fi

for i in {1..10}
do
	pid=`pidof $work`
	if [ $? -eq 0 ]
	then
		break
	elif [ $? -ne 0 ] && [ $i -eq 10 ]
	then
		echo "No pid found"
		exit 1
	fi
	echo 'wait for pidof '$work
	sleep 1
done

sudo $DAMO schemes -c $EXP_DIR/schemes/ethp.damos $pid
