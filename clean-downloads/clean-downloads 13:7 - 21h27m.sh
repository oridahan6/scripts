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
#files=($(find . -type f -iname "*.mkv" -or -iname "*.mp3"))
files=($(find $torrentsDir -type f))

#files=( "${files[@]##*/}" )

minimumSeriesSize=100000
maximumSeriesSize=2000000

minimumMovieSize=100000
maximumMovieSize=2000000


#testFile="Burn.Notice.S06E11.HDTVx264-2HD"
#echo "$testFile" | sed -e 's/\([sS][0-9][0-9][eE][0-9][0-9]\).*//'
#i=`echo $testFile | sed -n "s/S[0-9][0-9]E[0-9][0-9].*//p" | wc -c`
#echo "$i"

for file in ${files[*]}
do

	#series=`echo "$file" | grep -vE '[sS][0-9][0-9][eE][0-9][0-9]'`
	#echo "$series"
	echo "$file"
	if echo $file | grep -Eq '[sS][0-9][0-9][eE][0-9][0-9]'
	then
    	# code if found
    	echo "found"
	else
	    # code if not found
	    echo "not found"
fi
	
: <<'END'
	match=0
	FILESIZE=$(du -k "$file" | awk '{ print $1 }')
	if [ $FILESIZE -gt  $minimumSeriesSize -a $FILESIZE -lt  $maximumSeriesSize ]; then
		# TV Series
		echo "Size of $file = $FILESIZE."
		y=${file%.*}
		trimmedFile=${y##*/}
		dotSeriesName=`echo "$trimmedFile" | sed -e 's/\([\.| ][sS][0-9][0-9][eE][0-9][0-9]\).*//'`
		seriesName=`echo "$dotSeriesName" | sed -e 's/\./ /'`
		
		mkdir $"$seriesDir$seriesName"
		seriesDirs=($(find $seriesDir -maxdepth 1 -type d))
		for dir in ${seriesDirs[*]}
		do
			if echo "$dir" | grep -q "$seriesName"; then
				mv -v $file $dir
				match=1
				break;
			fi
			
		done
	fi 
END
done
# restore $IFS
IFS=$SAVEIFS