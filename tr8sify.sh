# Rename files to prefix-00N, where prefix is the name of the parent directory and 00N is the file index
# $1: source directory
# $2: target directory
# ./tr8sify.sh Src Dest

srcDir=$1
dstDir=$2
maxNumFiles=128 # Device limitations

error_exit()
{
  echo "$1" 1>&2
  exit 1
}

countDirs=0
for dir in ./$srcDir/*/; do
    countDirs=$(($countDirs+1))
    if (($countDirs > $maxNumFiles))
        then 
            error_exit "ERROR: You cannot process more than 128 directories!"
        else 
            splitBySlash=(${dir//// })
            # file name prefix will take the name of the directory it's in
            prefix=${splitBySlash[${#splitBySlash[@]}-1]}
            ls $dir | cat -n | while read count file; do 
                if (($count > $maxNumFiles))
                    then 
                        error_exit "ERROR: You cannot process more than 128 files within a directory!"
                    else
                        pathPrefix="./$dstDir/$prefix/"
                        mkdir -p $pathPrefix
                        splitByDot=(${file//./ })
                        # filename may have dots in it so assume extension is the string after the final dot
                        extension=${splitByDot[${#splitByDot[@]}-1]}
                        # pad with zeros to ensure every number string is the same length
                        printCount=$(printf "%03d\n" $count)
                        newName=$pathPrefix$prefix-$printCount.$extension
                        echo $dir$file " --> " $newName
                        cp -n "$dir$file" "$newName"
                fi
        done
    fi
done