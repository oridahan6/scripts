#!/bin/bash

shopt -s expand_aliases
source ~/.bash_profile

echo "match-subtitle.sh"

# directories
seriesDir=$1
echo "$seriesDir"

exit

test1


SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
# set me
files=($(find $seriesDir -type f))

minimumSeriesSize=100000
maximumSeriesSize=2000000

function getName {
    y=${file%.*}
	trimmedFile=${y##*/}
	dotSeriesName=`echo "$trimmedFile" | sed -e 's/\('$regex'\).*//'`
	echo $dotSeriesName
}
subtitles=`find $seriesDir -type f \( -name "*.srt" -or -name "*.sub" \)`

for file in ${files[*]}
do
	FILESIZE=$(du -k "$file" | awk '{ print $1 }')
# what if the file is like 08x05??
	    if [ $FILESIZE -gt  $minimumSeriesSize ]; then
			# TV Series
			regex="[sS][0-9][0-9][eE][0-9][0-9]"
			y=${file%.*}
			trimmedFile=${y##*/}
echo "trimmedFile: $trimmedFile"
            filename=$(basename "$file")
            extension="${filename##*.}"
echo "extension: $extension"

#			filename=`echo "$trimmedFile" | sed -e 's/.(mkv|mp4|avi)//'`
            filename=`echo "$trimmedFile" | sed -e 's/.$extension//'`
echo "filename: $filename"
			seasonAndEpisode=`echo "$file" | sed -e 's/.*\('$regex'\).*/\1/'`
echo "seasonAndEpisode: $seasonAndEpisode"

			dotFilename=${filename// /.}
echo "dotFilename1: $dotFilename"
			dotFilename=${dotFilename/\[*\]/}
echo "dotFilename2: $dotFilename"
#			if [[ "$file" == *.mp4 ]]; then
#				mv -v "$file" "$seriesDir$dotFilename.mp4"
#			elif [[ "$file" == *.mkv ]]; then
#				mv -v "$file" "$seriesDir$dotFilename.mkv"
#			elif [[ "$file" == *.avi ]]; then
#				mv -v "$file" "$seriesDir$dotFilename.avi"
#			else
#				echo "UNKNOWN VIDEO EXTENSTION"
#			fi
        newVideoFilename="$seriesDir$dotFilename.$extension"
#       mv -v "$file" "$newVideoFilename"
echo "newVideoFilename: $newVideoFilename"
			
		fi
		
		for subtitle in ${subtitles[*]}
		do
			subSeasonAndEpisode=`echo "$subtitle" | sed -e 's/.*\('$regex'\).*/\1/'`
			if [ "$seasonAndEpisode" != "" ]; then
				if [ "$seasonAndEpisode" == "$subSeasonAndEpisode" ]; then
					echo "newfilename: $seriesDir$dotFilename.srt"
#					mv -v $subtitle "$seriesDir$dotFilename.srt"
				fi
			fi
		done
echo "***************************************************************************************************************************************************"
done
# restore $IFS
IFS=$SAVEIFS