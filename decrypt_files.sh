#!/bin/ksh
#######################################################################################################
# FILENAME              : decrypt_files.sh
# PURPOSE               : Decrypt the input file, depending on parameter
# CREATED BY            : Murari Goswami
# DATE                  : 19/11/2013
# PARAMETERS            : ENCRYPTION    => Y or N
#                         SOURCE_DIR    => Source Directory for file
#                         FILE_PATTERN  => File Pattern
#                         DESTI_DIR     => Landing directory for encrypted file
# HISTORY               : This Utility was build in my Telefonica days.
#    					  A special Credit to David Jukes from Tesco Mobile who helped me to get the 
#						  idea to wrap the encryption logic in a single programme. 
#                         These program is complete in sense and can be inherited to build any custom 
#                         application to handle encryption for any files. 
#######################################################################################################

SCR_HOME=/home/tedload/tedjobs/script   # This the home directory for the script where the shell scripts are stored.

DECRYPTION=$1
SRC_DIR=$2
FILE_PATTERN=$3
PASSPHRASE=$4
param_req=$5
ops_email=$6
file_extn=gpg

param_pass=$#

. ${SCR_HOME}/common_log.sh                   # Calling common functions.

print_msg "################################# MAIN PROGRAM STARTS HERE #################################"
print_msg "Total Number of Parameters passed : $param_pass"
# Parameter Count Check
check_param_count $param_req $param_pass

# Data type check for parameters passed
check_string $DECRYPTION || fn_ErrorExit "Parameter Data Type Check Failure.."
check_string $SRC_DIR || fn_ErrorExit "Parameter Data Type Check Failure.."


local_tmp_file=/tmp/$$_local_push_files.tmp

# File availability check
cd $SRC_DIR

ls -n ${FILE_PATTERN}* | awk '{print $5 " " $9}' > $local_tmp_file

if [ ! -s $local_tmp_file ]
then
   rm -f $local_tmp_file
   print_msg "No files to decrypt"
   exit 0;
else
   print_msg "Files are present to encrypt. Go ahead"
fi

# Decryption Processing
if [ ${DECRYPTION} = "Y" ] || [ ${DECRYPTION} = "y" ] ; then

   print_msg "Decryption for below files STARTED.........."
   for i in `cat $local_tmp_file | awk '{print $2}'`
   do
      OUT_FILE=`basename ${i} .gpg`
      print_msg "Source Encrypted File Name : $i"
      print_msg "Decrypted File Name : ${OUT_FILE}"

      file_extension=`echo $i | awk -F "." '{print $3 }'`
      print_msg "File Extension: $file_extension"
      if [ "${file_extension}" != "gpg" ]
      then
        print_msg "Input file is not encrypted or the file is not correct to decrypt"
        exit 1;
      fi
      extension=`echo $i | grep -e ${file_extn}`
      if [ $? -eq 0 ]
      then
         print_msg "File is in correct format. Decrypting the file"
         print_msg "Extracting $i"
         decrypt_file ${PASSPHRASE} ${OUT_FILE} ${i} ${SRC_DIR}
         #echo "${PASSPHRASE}" | gpg --passphrase-fd 0 --batch -d --output ${OUT_FILE} "${i}"  #An alternative for direct call
         if  [ $? -ne 0 ]; then
             print_msg "Error in decrypting file - ${i}"
             mv -f ${i} Error_${i} # Renaming the file prefixed with error in order to skip this from processing
             chmod 755 ||         # Giving appropriate permissions.
             echo "Error in Decrypting File - ${i}" | mailx -s "Error in Decrypting File.." ${ops_email}
         fi
      else
         print_msg "Bad extension for the file. Please check"
         exit 1;
      fi
   done

elif [ $DECRYPTION = "N" ] || [ $DECRYPTION = "n" ] ; then

   print_msg "No Need to decrypt the below files"
   cat $local_tmp_file | awk '{print "... " $2}'
else
   print_msg "Invalid Mode. Re-Execute with correct decryption option - Y/N"
   exit 1;
fi
rm -f $local_tmp_file
print_msg ".............................Processing Completed................................"
