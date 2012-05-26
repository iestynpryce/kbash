#!/bin/bash
# Generates K clusters of data in a 2D environment, with a total ofN points
# Iestyn Pryce
# May 2012

function usage {
	echo $0 K N FILE
	echo K: Number of clusters
	echo N: Total number of points
	echo FILE: Filename to write to
}

if [ $# -ne 3 ]; then
	usage
	exit 1
fi

K=$1
N=$2
FILE=$3

# Blank the file
echo -n "" > $FILE

# Write out the samples
let M=$N/$K
for k in $(seq 1 $K); do
	#num=$(( RANDOM%$N ))
	num=10;
	let bias=$num*$k*$k
	echo "K: $k with xy mean $bias"
	for n in $(seq 1 $M); do
		x=$[ ($RANDOM%20) + $bias ]
		y=$[ ($RANDOM%20) + $bias ]
		
		d=$(printf '%d %d %d' $k $x $y)
		echo $d >> $FILE
	done
done
