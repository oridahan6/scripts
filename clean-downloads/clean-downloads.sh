#!/bin/bash

shopt -s expand_aliases
source ~/.bash_profile

echo "Clean-downloads.sh"

# directories
torrentsDir=/Volumes/Dahan/Downloads/uTorrent/Downloads/
seriesDir=/Volumes/Dahan/Videos/TV\ Series/
moviesDir=/Volumes/Dahan/Videos/Movies/
workingDir=$1

# const
minimumVideoSize=100000
maximumSeriesSize=2000000
minimumMovieSize=2000000
maximumMovieSize=20000000

seriesIndex=0
moviesIndex=0

# tmp files
mkdir -p /tmp/clean-downloads/
tmpDir=/tmp/clean-downloads/
touch $tmpDir/SeriesMoves.txt
touch $tmpDir/MoviesMoves.txt
touch $tmpDir/emailText.txt

# regex
seriesRegex1='[sS][0-9][0-9][eE][0-9][0-9]'
seriesRegex2='[0-9][0-9][xX][0-9][0-9]'
seriesRegex3='[0-9][0-9][0-9]'
moviesRegex='[0-9][0-9][0-9][0-9]'
hdRegex="[0-9][0-9][0-9][p|P]"
threeDRegex="3[dD]"

function getDotName {
    fileName=`echo "$1" | sed -e 's/\([\.| ]'$2'\).*//'`
    dotName=`echo "$fileName" | sed -e 's/ /\./g'`
    echo $dotName
}

function getName {
    videoName=`echo "$1" | sed -e 's/\./ /g'`
#
# NOTE: is it necessary to capitalize the series name?
#   echo $videoName
    IFS=$SAVEIFS
    for i in $videoName; do
        B=`echo -n "${i:0:1}" | tr "[:lower:]" "[:upper:]"`
        test="$test`echo -n "${B}${i:1} "`"
    done
    IFS=$(echo -en "\n\b")
    returnVideoName=`echo "$test" | sed 's/ *$//g'`
    echo $returnVideoName
}

function getTargetDir {
    if [[ "$1" =~ $2 ]]; then 
		echo "$3"
    else
		echo "$4"
    fi
}

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

files=($(find $workingDir -type f))
echo "before"
for file in ${files[*]}
do
    FILESIZE=$(du -k "$file" | awk '{ print $1 }')
    y=${file%.*}
    trimmedFile=${y##*/}
	if [[ "$file" =~ $seriesRegex1 ]] || [[ "$file" =~ $seriesRegex2 ]] || [[ "$file" =~ $seriesRegex3 ]]; then
#        if [ $FILESIZE -gt  $minimumVideoSize ] && [ $FILESIZE -lt  $maximumSeriesSize ]; then
echo "first if"
        if [[ "$file" =~ [D|d][v|V][D|d][R|r]ip ]] || [[ "$file" =~ [B|b]lu[R|r]ay ]] || [[ "$file" =~ 3[dD] ]]; then
            if [ $FILESIZE -gt  $minimumVideoSize ]; then
                # Movies
echo "Movies"
                dotMovieName=`getDotName $trimmedFile $moviesRegex`
                movieName=`getName $dotMovieName`
                threeDTargetDir="$moviesDir/3D/$movieName"
                twoDTargetDir="$moviesDir/2D/$movieName"
                targetDir=`getTargetDir $file $threeDRegex $threeDTargetDir $twoDTargetDir`
echo "targetDir: $targetDir"
                mkdir -p "$targetDir"
                mv -v $file $targetDir
                moviesIndex=$(($moviesIndex+1))
                echo "$moviesIndex. Moved $file -> $targetDir/." >> $tmpDir/MoviesMoves.txt
            fi
#        elif [ $FILESIZE -gt  $minimumMovieSize ]; then
        elif [ $FILESIZE -gt  $minimumVideoSize ]; then
            # TV Series
echo "TV"
            filename=$(basename "$file")
            extension="${filename##*.}"
            if [[ "$file" =~ $seriesRegex1 ]]; then
                dotSeriesName=`getDotName $trimmedFile $seriesRegex1`
                seriesName=`getName $dotSeriesName`
                season=`echo "$file" | sed -e 's/.*\([sS][0-9][0-9]\).*/\1/'`
                newFilename="$trimmedFile.$extension"
            elif [[ "$file" =~ $seriesRegex2 ]]; then
                dotSeriesName=`getDotName $trimmedFile $seriesRegex2`
                seriesName=`getName $dotSeriesName`
                xSeason=`echo "$file" | sed -e 's/.*\([0-9][0-9][xX]\).*/\1/'`
                season="S`echo "$xSeason" | sed -e 's/\([xX]\)//'`"
                xEpisode=`echo "$file" | sed -e 's/.*\([xX][0-9][0-9]\).*/\1/'`
                episode="E`echo "$xEpisode" | sed -e 's/\([xX]\)//'`"
                seasonAndEpisode="$season$episode"
                newFilename="$dotSeriesName.$seasonAndEpisode.$extension"
            elif [[ "$file" =~ $seriesRegex3 ]]; then
                dotSeriesName=`getDotName $trimmedFile $seriesRegex3`
                seriesName=`getName $dotSeriesName`
                if [[ "$file" =~ [0-9][0-9][0-9][0-9] ]]; then
                    dotSpaceSeason=`echo "$file" | sed -e 's/.*\([.| ][0-9][0-9]\).*/\1/'`
                    season="S`echo "$dotSpaceSeason" | sed -e 's/.*\([0-9][0-9]\).*/\1/'`"
                else
                    oneDigitDotSpaceSeason=`echo "$file" | sed -e 's/.*\([.| ][0-9]\).*/\1/'`
                    season="S0`echo "$oneDigitDotSpaceSeason" | sed -e 's/.*\([0-9]\).*/\1/'`"
            fi
            dotSpaceEpisode=`echo "$file" | sed -e 's/.*\([0-9][0-9][.| ]\).*/\1/'`
            episode="E`echo "$dotSpaceEpisode" | sed -e 's/.*\([0-9][0-9]\).*/\1/'`"
            seasonAndEpisode="$season$episode"
            newFilename="$dotSeriesName.$seasonAndEpisode.$extension"
            fi
            hdTargetDir="$seriesDir$seriesName/HD/$season"
            sdTargetDir="$seriesDir$seriesName/SD/$season"
            targetDir=`getTargetDir $file $hdRegex $hdTargetDir $sdTargetDir`
echo "targetDir: $targetDir"
            mkdir -p "$targetDir"
            mv -v $file "$targetDir/$newFilename"
            # ADD OPTION TO REMOVE FOLDER AFTER MOVING FILE
            seriesIndex=$(($seriesIndex+1))
            echo "$seriesIndex. Moved $file -> $targetDir/$newFilename." >> $tmpDir/SeriesMoves.txt

        fi
    fi
done
# restore $IFS
IFS=$SAVEIFS

# Prepare email's body
echo "Cleaned Downloads/ directory!" >> $tmpDir/emailText.txt
echo >> $tmpDir/emailText.txt

if [ "$moviesIndex" != 0 ] || [ "$seriesIndex" != 0 ]; then
    echo "$(($moviesIndex+$seriesIndex)) files were moved." >> $tmpDir/emailText.txt
    echo >> $tmpDir/emailText.txt
fi
if [ "$seriesIndex" != 0 ]; then
    echo "TV Series ($seriesIndex files):" >> $tmpDir/emailText.txt
    cat $tmpDir/SeriesMoves.txt >> $tmpDir/emailText.txt
    echo >> $tmpDir/emailText.txt
else
    echo "No TV Series were moved." >> $tmpDir/emailText.txt
    echo >> $tmpDir/emailText.txt
fi
if [ "$moviesIndex" != 0 ]; then
    echo "Movies ($moviesIndex files):" >> $tmpDir/emailText.txt
    cat $tmpDir/MoviesMoves.txt >> $tmpDir/emailText.txt
    echo >> $tmpDir/emailText.txt
else
    echo "No Movies were moved." >> $tmpDir/emailText.txt
    echo >> $tmpDir/emailText.txt
fi

cat $tmpDir/emailText.txt | mail -s "Downloads cleaned" ori.dahan6@gmail.com
#cp -f $tmpDir/emailText.txt "/Volumes/Dahan/Downloads/uTorrent/Downloads/emailText $(date +"%Y-%m-%d.%Hh%Mm").txt"

rm -rf $tmpDir