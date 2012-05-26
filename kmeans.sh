#!/bin/bash
# Performs kmeans on 2D data
# Iestyn Pryce
# May 2012
# Current assumption on 2D data

#function read_file {
#	
#}

function square_dist {
	data1="$1";
	data2="$2";
	mu="$3";

	let d1=$data1-$(echo $mu|cut -f1 -d ' ');
	let d2=$data2-$(echo $mu|cut -f2 -d ' ');
	let d1*=$d1;let d2*=$d2;
	r=$(echo "sqrt ( $d1 + $d2 )" | bc -l );
	echo $r;
}

function find_nearest {
	ret=$(echo "$1 <= $2" | bc -l);
	if [ $ret -eq 1 ]; then
		echo 1;
	else
		echo 2;
	fi;
}

function usage {
	echo $0 FILE K
	echo FILE: data file
	echo K: number of clusters
}

# Check we have the right number of arguments
if [ $# -ne 2 ]; then
	usage
	exit 1
fi

FILE=$1
K=$2

# Make sure $mu is an array
declare -a mu

# Randomly initialize the means
for i in $(seq 1 $2); do
	mu[$i]="$((RANDOM%30)) $((RANDOM%30))"
	echo Mean $i: ${mu[$i]}
done

# Read in the data
let n=0;
while IFS= read -r line <&3; do
	data[$n]="$line"
	data1[$n]=$(echo "$line" | cut -d ' ' -f 2)
	data2[$n]=$(echo "$line" | cut -d ' ' -f 3)
	let n+=1;
done 3<$FILE
let N=n-1

for l in $(seq 1 10); do

# Associate each data point with its closest mean
for n in $(seq 0 $N); do
	distance1[$n]=$(square_dist ${data1[$n]} ${data2[$n]} "${mu[1]}")
	distance2[$n]=$(square_dist ${data1[$n]} ${data2[$n]} "${mu[2]}")
	nearest[$n]=$(find_nearest "${distance1[$n]}" "${distance2[$n]}")
done

# Recalculate the means
num1=0; num2=0;
mx1=0;my1=0;mx2=0;my2=0;
for j in $(seq 0 $N); do
	ind=${nearest[$j]}
	if [ $ind -eq 1 ]; then
		let mx1+=${data1[$j]}
		let my1+=${data2[$j]}
		let num1+=1
	else
		let mx2+=${data1[$j]}
		let my2+=${data2[$j]}
		let num2+=1
	fi		
done
let mx1/=$num1; let my1/=$num1
let mx2/=$num2; let my2/=$num2

mu[1]="$mx1 $my1";
mu[2]="$mx2 $my2";

#echo "mu[1]: ${mu[1]}"
#echo "mu[2]: ${mu[2]}"

done

echo ${mu[1]}
echo ${mu[2]}
