#!/bin/bash

shopt -s expand_aliases
source ~/.bash_profile

echo "Clean-downloads.sh"

# directories
currDir=`pwd`
torrentsDir=/Volumes/Dahan/Downloads/uTorrent/Downloads/
seriesDir=/Volumes/Dahan/Videos/TV\ Series/
moviesDir=/Volumes/Dahan/Videos/Movies/

tmpDir="$torrentsDir/tmp"
echo "$tmpDir"
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
# set me
files=($(find $torrentsDir -type f))

minimumSeriesSize=100000
maximumSeriesSize=2000000

minimumMovieSize=2000000
maximumMovieSize=20000000

mkdir -p /tmp/clean-downloads/
tmpDir=/tmp/clean-downloads/
touch $tmpDir/SeriesMoves.txt
touch $tmpDir/MoviesMoves.txt


echo "test" >> $tmpDir/SeriesMoves.txt


function getName {
    y=${file%.*}
	trimmedFile=${y##*/}
	dotSeriesName=`echo "$trimmedFile" | sed -e 's/\([\.| ]'$regex'\).*//'`
	seriesName=`echo "$dotSeriesName" | sed -e 's/\./ /g'`
	echo $seriesName
}

for file in ${files[*]}
do
	FILESIZE=$(du -k "$file" | awk '{ print $1 }')
	if echo $file | grep -Eq '[sS][0-9][0-9][eE][0-9][0-9]'; then
	    if [ $FILESIZE -gt  $minimumSeriesSize ]; then
			# TV Series
			regex="[sS][0-9][0-9][eE][0-9][0-9]"
			seriesName=`getName $file $regex`
			season=`echo "$file" | sed -e 's/.*\([sS][0-9][0-9]\).*/\1/'`
			targetDir="$seriesDir$seriesName/$season"
			if [[ "$file" =~ [0-9][0-9][0-9][p|P] ]]; then 
			    targetDir="$seriesDir$seriesName/HD/$season"
			else
			    targetDir="$seriesDir$seriesName/SD/$season"
            fi
			currentDir=`dirname $file`
			echo "$torrentsDir"
			echo "$currentDir/"
			#mkdir -p "$targetDir"
			#mv -v $file $targetDir
			
			# ADD OPTION TO REMOVE FOLDER AFTER MOVING FILE
		
			#if [ "$currentDir/" != "$torrentsDir" ]; then
			#   echo "remove"
			#   rm -rf $currentDir
			#fi

		fi
	elif [ $FILESIZE -gt  $minimumMovieSize ]; then
		# Movies
		regex="[0-9][0-9][0-9]"
		movieName=`getName $file $regex`
	    echo $movieName
	    is3D=`echo "$file" | sed -e 's/.*\(3[Dd]\).*/\1/'`
	    echo "$is3D"
	    if [[ "$file" =~ 3[dD] ]]; then
	        targetDir="$moviesDir/3D/$movieName"
	        echo "$targetDir"
	    else
	        targetDir="$moviesDir/2D/$movieName"
	        echo "$targetDir"
	    fi
	    #mkdir -p "$targetDir"
	    #mv -v $file $targetDir
	    
	fi
done
# restore $IFS
IFS=$SAVEIFS
#rm -rf $tmpDir