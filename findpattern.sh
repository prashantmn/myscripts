#!/bin/bash
# findpattern.sh - Takes file name as first argument, and string input as second
# Caveat - Thing to remember for string with special character. For regex patterns, any special char (like ?) needs to be escaped. But looks like patttest considers a pattern to be regex, and it does not match if specail char is not escaped, though its a simple pattern. (special chars in simple patterns dont need to be escaped) 
# ./pattest -s "/live-tv?trknav" -p "/live-tv\?trknav" -- Its a match
# ./pattest -s "/live-tv?trknav" -p "/live-tv?trknav" --  No match
#

# Arg check
if [[ $# -lt 1 || $# -gt 3 ]] ; then 
        echo "Usage: findpattern.sh  <file>  <string> [--skip]"
        echo "Ex: findpattern  quote.include  '/quotes/?symbol=CMCSA&qsearchterm=QQQ'"
        echo "--skip: Skips processing include file ending with pub-fill-from-pub.include"
        echo "Please manually verify the rule using the line number displayed as the actual pattern section might have additional rules"
        exit
fi

INFILE=$1
STRING=$2
OUTFILE=/tmp/patterns.outfile
cp /dev/null $OUTFILE
echo -e "\nPattern: $STRING \n"
linenum=1

while IFS= read -r line
do
        # Process each line while looking for include file
        echo $line | grep ^include > /dev/null
        if [ $? -eq 0 ]; then
                file=`echo $line | awk '{print $2}'`
                if [[ $file =~ .*pub-fill-from-pub.include$ ]] && [[ $3 = "--skip" ]] ; then
                        echo "Skipping $file"
                        continue
                fi
                #echo "File: $file"
                #echo "Patterns from $file"
                # Get all the patterns from included file
                linenum2=1
                while IFS= read -r line2
                do 
                        let linenum2=$linenum2+1
                        echo $line2 | grep ^pattern > /dev/null
                        if [ $? -eq 0 ] ; then
                                pattern2=`echo $line2 | awk '{print $2}'`
                                #echo $pattern2
                                echo $pattern2 >> $OUTFILE
                                # match for string
                                /usr/local/aicache/pattest -p $pattern2 -s $STRING > /dev/null 2>&1
                                if [ $? -eq 0 ] ; then 
                                        echo "File: $file   Line: $linenum2   Matching Pattern: $pattern2"
                                        #break
                                fi
                        fi
                done < $file
        fi

        # Get all the patterns from main include file
        echo $line | grep ^pattern > /dev/null
        if [ $? -eq 0 ] ; then
                pattern=`echo $line | awk '{print $2}'`
                #echo "Main file pattern: $pattern"
                echo $pattern >> $OUTFILE
                # match for string
                /usr/local/aicache/pattest -p $pattern -s $STRING > /dev/null 2>&1
                if [ $? -eq 0 ] ; then
                        echo "File: $INFILE  Line: $linenum    Matching Pattern: $pattern"
                        #break
                fi
        fi

        let linenum=$linenum+1

done < $INFILE
