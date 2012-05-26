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

# Returns the index with the minimum value in an array
function find_nearest {
	declare -a dist=("${!1}");
	I=$(tr ' ' '\n' <<<${dist[@]} | cat -n | sort -k2,2n | head -n1 | cut -f1);
	echo $I
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
for i in $(seq 1 $K); do
	mu[$i]="$((RANDOM%30)) $((RANDOM%30))"
	echo Initial Mean $i: ${mu[$i]}
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
	for k in $(seq 1 $K); do
		distance[$k]=$(square_dist ${data1[$n]} ${data2[$n]} "${mu[$k]}")
	done
	nearest[$n]=$(find_nearest distance[@])
done

# Recalculate the means
for k in $(seq 1 $K); do

	num=0;
	mx=0;
	my=0;
	for j in $(seq 0 $N); do
		ind=${nearest[$j]}
		if [ $ind -eq $k ]; then
			let mx+=${data1[$j]}
			let my+=${data2[$j]}
			let num+=1
		fi		
	done
	# if no data points are associated with the cluster
	# set it to 0,0
	if [[ $num == 0 ]]; then
		echo "No data is in cluster $k (${mu[$k]})" 1>&2;
		mx=0; my=0;
	else
		let mx/=$num; let my/=$num;
	fi
	mu[$k]="$mx $my";

	# Echo the cluster mean values at this iteration
	#echo "$k: ${mu[$k]}";
done

done # end learning loop

for k in $(seq 1 $K); do
	echo ${mu[$k]}
done;
