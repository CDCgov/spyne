
#!/bin/bash
# Wrapper to install downloaded packages 

PACKAGE_ROOT=/opt/bbtools
BBTOOLS_PROGRAM_DIR=${BBTOOLS_PROGRAM_DIR:-/bbtools}
bbtools_orig=${BBTOOLS_PROGRAM_DIR}/bbtools_file.txt
bbtools_clean=${BBTOOLS_PROGRAM_DIR}/bbtools_file_clean.txt

# Make the bbtools directory exits, if not, create it
if [[ ! -d ${PACKAGE_ROOT} ]]
then
	mkdir ${PACKAGE_ROOT}
fi

# Extract bbmap package to the bbtools directory
if [[ -f ${bbtools_orig} ]]
then

	echo "Install bbtools"

	# Remove blank lines from the file and save a cleaner version of it
	awk NF < ${bbtools_orig} > ${bbtools_clean}

	# Get number of rows in bbtools_file_clean.txt
	n=`wc -l < ${bbtools_clean}`
	i=1

	# Get the file and install the package
	while [[ i -le $n ]];
	do
		echo $i
		file=$(head -${i} ${bbtools_clean} | tail -1 | sed 's,\r,,g')
		echo $file
		# Check if file exists
		if [[ -f ${BBTOOLS_PROGRAM_DIR}/${file} ]]
		then
			echo "Extract bbmap"
			tar -zxf ${BBTOOLS_PROGRAM_DIR}/${file} -C ${PACKAGE_ROOT}
		fi
		i=$(($i+1))
	done
	
	# return message to keep the process going
	echo "Done"

fi