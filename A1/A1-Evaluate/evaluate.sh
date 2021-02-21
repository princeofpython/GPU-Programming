#!/bin/bash

#Do NOT Terminate terminate with a "/"
SUBMIT=/content/drive/MyDrive/A1-Evaluate/A1-Submit
INPUT=/content/drive/MyDrive/A1-Evaluate/A1-tc
OURSRC=/content/drive/MyDrive/A1-Evaluate/src


MARKSFILE=$OURSRC/A1-Marks.txt

echo "====================START==========================" >> $MARKSFILE
date >> $MARKSFILE

for FOLDER in $SUBMIT/*
do
	#! echo FOLDER NAME : "${FOLDER}"
	cd "${FOLDER}"
	
	ROLLNO=$(ls *.cu | tail -1 | cut -d'.' -f1)
	LOGFILE=${ROLLNO}.log
	
	# check for single source file. If not halt script!
	if [ $(ls | wc -l) -ne 1 ] 
	then
		echo "May be cleanup files! (delete all files in 'A1-Submit/<ROLLNO>' folder except ROLLNO.cu) and run evaluate.sh!"
		break
	fi
	
	# cp require/our src files to stud's folder and build
	cp ${ROLLNO}.cu kernels.cu
	cp "$OURSRC/main.cu" .
	cp "$OURSRC/makefile" .
	cp "$OURSRC/kernels.h" .
	make   #creates ./main.out  &> /dev/null
	
	# If build fails? then skip to next stud
	if [ $? -ne 0 ] 
	then
		echo $ROLLNO,BUILD FAILED!
    echo $ROLLNO,BUILD FAILED! >> $MARKSFILE # write to file     
		cd ../.. # MUST
		continue
	fi
		
	date > $LOGFILE
	
  ./main.out ${INPUT}/input1.txt               >> $LOGFILE
  ./main.out ${INPUT}/input2.txt               >> $LOGFILE
  ./main.out ${INPUT}/input3.txt               >> $LOGFILE 
  
	SCORE=$(grep -ic success $LOGFILE) #Counts the success in log
	#! TOTAL=$(ls $INPUT/*.txt | wc -l)
	echo $ROLLNO,$SCORE 
	echo $ROLLNO,$SCORE >> $MARKSFILE # write to file 
	
	# IMPORTANT
	cd ../..
done

date >> $MARKSFILE
echo "====================DONE!==========================" >> $MARKSFILE

