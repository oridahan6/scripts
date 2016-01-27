#!/bin/bash

shopt -s expand_aliases
source ~/.bash_profile

echo "Clean-downloads.sh"

# directories
currDir=`pwd`
torrentsDir=/Volumes/Dahan/Downloads/uTorrent/Downloads/
seriesDir=/Volumes/Dahan/Videos/TV\ Series/


SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
# set me
files=($(find $torrentsDir -type f))

minimumSeriesSize=100000
maximumSeriesSize=2000000

minimumMovieSize=2000000
maximumMovieSize=20000000

for file in ${files[*]}
do

#if [ $FILESIZE -gt  $minimumSeriesSize -a $FILESIZE -lt  $maximumSeriesSize ]; then
isSeries=`echo $file | grep -Eq '[sS][0-9][0-9][eE][0-9][0-9]'`
	match=0
	FILESIZE=$(du -k "$file" | awk '{ print $1 }')
	if echo $file | grep -Eq '[sS][0-9][0-9][eE][0-9][0-9]'; then
	    if [ $FILESIZE -gt  $minimumSeriesSize ]; then
			# TV Series
			echo "Size of $file = $FILESIZE."
			y=${file%.*}
			trimmedFile=${y##*/}
			dotSeriesName=`echo "$trimmedFile" | sed -e 's/\([\.| ][sS][0-9][0-9][eE][0-9][0-9]\).*//'`
			seriesName=`echo "$dotSeriesName" | sed -e 's/\./ /'`
			season=`echo "$file" | sed -e 's/.*\([sS][0-9][0-9]\).*/\1/'`
			targetDir="$seriesDir$seriesName/$season"
			echo "$targetDir"
			mkdir $targetDir
			#mkdir $"$seriesDir$seriesName/$season"
			#mkdir $"$seriesDir$seriesName"
			#seriesDirs=($(find $seriesDir -maxdepth 1 -type d))
			#for dir in ${seriesDirs[*]}
			#do
				#if echo "$dir" | grep -q "$seriesName"; then
					mv -v $file $targetDir
					#match=1
					#break;
				#fi	
			#done
		fi
	elif [ $FILESIZE -gt  $minimumMovieSize ]; then
		echo "movies"
		#echo "$file"
		 
	fi

done
# restore $IFS
IFS=$SAVEIFS