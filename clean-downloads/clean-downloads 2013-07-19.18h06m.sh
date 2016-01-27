#!/bin/bash

shopt -s expand_aliases
source ~/.bash_profile

echo "Clean-downloads.sh"

# directories
currDir=`pwd`
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
hdRegex="[0-9][0-9][0-9][p|P]"

function getDotName {
    fileName=`echo "$1" | sed -e 's/\([\.| ]'$2'\).*//'`
    dotName=`echo "$fileName" | sed -e 's/ /\./g'`
    echo $dotName
}

function getName {
#y=${1%.*}
#	trimmedFile=${y##*/}
#	dotSeriesName=`echo "$trimmedFile" | sed -e 's/\([\.| ]'$2'\).*//'`
    seriesName=`echo "$1" | sed -e 's/\./ /g'`
#
#NOTE: is it necessary to capitalize the series name?
#
#   echo $seriesName
    IFS=$SAVEIFS
    for i in $seriesName; do
        B=`echo -n "${i:0:1}" | tr "[:lower:]" "[:upper:]"`
        test="$test`echo -n "${B}${i:1} "`"
    done
    IFS=$(echo -en "\n\b")
    returnSeriesName=`echo "$test" | sed 's/ *$//g'`
    echo $returnSeriesName
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
# set me
files=($(find $workingDir -type f))

for file in ${files[*]}
do

    FILESIZE=$(du -k "$file" | awk '{ print $1 }')




#    if echo $file | grep -Eq '[0-9][0-9][0-9]'; then
#        echo $file
#        echo "isSeries"
#    fi
#   echo $file
#if [[ "$file" =~ [0-9][0-9][0-9]^[0-9] ]] || [[ "$file" =~ [sS][0-9][0-9][eE][0-9][0-9] ]] || [[ "$file" =~ [0-9][0-9][xX][0-9][0-9] ]]; then
#   if [ $FILESIZE -gt  $minimumVideoSize ]; then
#        if [[ "$file" =~ [0-9][0-9][0-9][0-9] ]]; then
#            echo "isMovies"
#        else
#            echo "isSeries"
#        fi
#    fi
#fi

    y=${file%.*}
    trimmedFile=${y##*/}
    echo "trimmedFile: $trimmedFile"
	if [[ "$file" =~ $seriesRegex1 ]] || [[ "$file" =~ $seriesRegex2 ]] || [[ "$file" =~ $seriesRegex3 ]]; then

        if [ $FILESIZE -gt  $minimumVideoSize ] && [ $FILESIZE -lt  $maximumSeriesSize ]; then
            # TV Series
            
            #
            # NOTE: Handle files that has special season and episode:
            # new.girl.201.hdtv or American Dad - 08x05
            #


#extension=`getFileExtension $file`
#echo "extension: $extension"
            filename=$(basename "$file")
            extension="${filename##*.}"
            echo "extension: $extension"

            
            echo "file: $file"

            if [[ "$file" =~ $seriesRegex1 ]]; then
                echo "seriesRegex1"
                dotSeriesName=`getDotName $trimmedFile $seriesRegex1`
                echo "dotSeriesName: ***$dotSeriesName***"
                seriesName=`getName $dotSeriesName`
                echo "series name: $seriesName"
                season=`echo "$file" | sed -e 's/.*\([sS][0-9][0-9]\).*/\1/'`
                echo "season: $season"
                echo "trimmedFile: $trimmedFile"
                newFilename="$trimmedFile.$extension"
                echo "newFilename: $newFilename"
            elif [[ "$file" =~ $seriesRegex2 ]]; then
                echo "seriesRegex2"
                dotSeriesName=`getDotName $trimmedFile $seriesRegex2`
                echo "dotSeriesName: ***$dotSeriesName***"
                seriesName=`getName $dotSeriesName`
                echo "$seriesName"
                xSeason=`echo "$file" | sed -e 's/.*\([0-9][0-9][xX]\).*/\1/'`
                season="S`echo "$xSeason" | sed -e 's/\([xX]\)//'`"
                xEpisode=`echo "$file" | sed -e 's/.*\([xX][0-9][0-9]\).*/\1/'`
                episode="E`echo "$xEpisode" | sed -e 's/\([xX]\)//'`"
                seasonAndEpisode="$season$episode"
                echo "seasonAndEpisode: $seasonAndEpisode"
                echo "trimmedFile: $trimmedFile"
                newFilename="$dotSeriesName.$seasonAndEpisode.$extension"
                echo "newFilename: $newFilename"
            elif [[ "$file" =~ $seriesRegex3 ]]; then
                echo "seriesRegex3"
                dotSeriesName=`getDotName $trimmedFile $seriesRegex3`
                echo "dotSeriesName: ***$dotSeriesName***"
                seriesName=`getName $dotSeriesName`
                echo "$seriesName"
                if [[ "$file" =~ [0-9][0-9][0-9][0-9] ]]; then
                    echo "2 digits season"
                    dotSpaceSeason=`echo "$file" | sed -e 's/.*\([.| ][0-9][0-9]\).*/\1/'`
                    echo "dotSpaceSeason: ***$dotSpaceSeason***"
                    season="S`echo "$dotSpaceSeason" | sed -e 's/.*\([0-9][0-9]\).*/\1/'`"
                    echo "season: ***$season***"
                else
                    echo "1 digit season"
                    oneDigitDotSpaceSeason=`echo "$file" | sed -e 's/.*\([.| ][0-9]\).*/\1/'`
                    echo "oneDigitDotSpaceSeason: ***$oneDigitDotSpaceSeason***"
                    season="S0`echo "$oneDigitDotSpaceSeason" | sed -e 's/.*\([0-9]\).*/\1/'`"
                    echo "season: ***$season***"
                fi
                dotSpaceEpisode=`echo "$file" | sed -e 's/.*\([0-9][0-9][.| ]\).*/\1/'`
                echo "dotSpaceEpisode: ***$dotSpaceEpisode***"
                episode="E`echo "$dotSpaceEpisode" | sed -e 's/.*\([0-9][0-9]\).*/\1/'`"
                echo "episode: ***$episode***"
                seasonAndEpisode="$season$episode"
                echo "seasonAndEpisode: $seasonAndEpisode"
                newFilename="$dotSeriesName.$seasonAndEpisode.$extension"
                echo "newFilename: $newFilename"

            fi
            targetDir="$seriesDir$seriesName/$season"
            #if [[ "$file" =~ [0-9][0-9][0-9][p|P] ]]; then 
            #    targetDir="$seriesDir$seriesName/HD/$season"
            #else
            #    targetDir="$seriesDir$seriesName/SD/$season"
            #fi
hdTargetDir="$seriesDir$seriesName/HD/$season"
           sdTargetDir="$seriesDir$seriesName/SD/$season"

#            targetDir=`getTargetDir $file $hdRegex $hdTargetDir $sdTargetDir`
targetDir=`getTargetDir $file $hdRegex $hdTargetDir $sdTargetDir`
echo "targetDir: $targetDir"
mkdir -p "$targetDir"



mv -v $file "$targetDir/$newFilename"
            
            # ADD OPTION TO REMOVE FOLDER AFTER MOVING FILE
            seriesIndex=$(($seriesIndex+1))
            echo "$seriesIndex. Moved $file -> $targetDir/$newFilename." >> $tmpDir/SeriesMoves.txt
    
        elif [ $FILESIZE -gt  $minimumMovieSize ]; then
            # Movies
            echo "Movies"
            regex="[0-9][0-9][0-9]"
            dotMovieName=`getDotName $trimmedFile $regex`
            echo "dotMovieName: $dotMovieName"
            movieName=`getName $dotMovieName`
            echo "movieName: $movieName"
#            is3D=`echo "$file" | sed -e 's/.*\(3[Dd]\).*/\1/'`
#            echo "is3D: $is3D"
            #if [[ "$file" =~ 3[dD] ]]; then
            #    targetDir="$moviesDir/3D/$movieName"
            #else
            #    targetDir="$moviesDir/2D/$movieName"
            #fi
            threeDTargetDir="$moviesDir/3D/$movieName"
            twoDTargetDir="$moviesDir/2D/$movieName"
            threeDRegex="3[dD]"
            targetDir=`getTargetDir $file $threeDRegex $threeDTargetDir $twoDTargetDir`
echo "targetDir: $targetDir"
           mkdir -p "$targetDir"
mv -v $file $targetDir
            moviesIndex=$(($moviesIndex+1))
            echo "$moviesIndex. Moved $file -> $targetDir/." >> $tmpDir/MoviesMoves.txt
            
        fi
    fi
     echo "************************"
done
# restore $IFS
IFS=$SAVEIFS

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


cp -f $tmpDir/emailText.txt "/Volumes/Dahan/Downloads/uTorrent/Downloads/emailText $(date +"%Y-%m-%d.%Hh%Mm").txt"

rm -rf $tmpDir