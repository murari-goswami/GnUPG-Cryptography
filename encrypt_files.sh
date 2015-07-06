#!/bin/ksh
##################################################################################################
# FILE NAME             : encrypt_files.sh
# PURPOSE               : Encrypt the input file, depending on parameter
# CREATED BY            : Murari Goswami
# DATE                  : 12/11/2013
# USAGE                 : [ENCRYPTION]    => Y or N
#                         [USER]          => User Name
#                         [SOURCE_DIR]    => Source Directory for file
#                         [FILE_PATTERN]  => File Pattern
#                         [DESTI_DIR]     => Landing directory for encrypted file
#
# HISTORY               : This Utility was build in my Telefonica days.
#    					  A special Credit to David Jukes from Tesco Mobile who helped me to get the 
#						  idea to wrap the encryption logic in a single programme. 
#                         These program is complete in sense and can be inherited to build any custom 
#                         application to handle encryption for any files.   
###################################################################################################

. common_log.sh      # Calling logging env file details - This file has set of different utilities 

ENCRYPTION=$1
USER=$2
SRC_DIR=$3
FILE_PATTERN=$4
DEST_DIR=$5

param_req=5          # Though hard coded in nature, this will make sure the number of formal arguments required in the programme
param_pass=$#        # To check the exact number of arguments passed while calling the programme

fn_encrypt_file()
{

   encrypt_file "$1" $2 $3
   return_val=$?


}
##################################################### MAIN PROGRAM STARTS HERE ##############################################################

# Parameter Count Check
check_param_count $param_req $param_pass

# Data type check for encryption value
check_string $ENCRYPTION

local_tmp_file=/tmp/$$_local_push_files.tmp

# File availability check
cd $SRC_DIR || fn_ErrorExit "Problem while changing directory to source directory"

ls -n ${FILE_PATTERN}* | awk '{print $5 " " $9}' > $local_tmp_file

if [ ! -s $local_tmp_file ]
then
   rm -f $local_tmp_file
   print_msg "No files to encrypt"
   exit 1;
else
   print_msg "Files are present to encrypt. Go ahead"
fi

# Encryption Processing
if [ $ENCRYPTION = "Y" ] || [ $ENCRYPTION = "y" ] ; then
   print_msg "Encryption for below files STARTED.........."
   for i in `cat $local_tmp_file | awk '{print $2}'`
   do
      print_msg "File Name : $i"
      file_extension=`echo $i | awk -F "." '{print $3 }'`
      print_msg "File Extension: $file_extension"

      extension=`echo $i | grep -e "gz" -e "Z"`
      if [ $? != 0 ] ; then
         print_msg "File is in correct format. Encrypt the file"
         encrypt_file "$USER" $SRC_DIR $i
         return_val=$?
         if [ $return_val -eq 0 ]; then
            print_msg "Encryption Successful"
         else
            print_msg "Fail to encrypt"
            exit 1
         fi

      elif [ "${file_extension}" = "gz" ] ; then
         print_msg "File is in zip format"
         print_msg "Unzip the file to encrypt"
         gunzip $i
         new_file_name=`echo $i | awk -F ".gz" '{print $1 }'`
         print_msg "Encrypt the file"
         encrypt_file "$USER" $SRC_DIR $new_file_name
         return_val=$?
         if [ $return_val -eq 0 ]; then
            print_msg "Encryption Successful"
         else
            print_msg "Fail to encrypt"
            gzip -v $SRC_DIR/$new_file_name || fn_ErrorExit "Problem while zipping the file"
            exit 1
         fi

      elif  [ ${file_extension} = "Z" ] ; then
         print_msg "File is in compressed format"
         print_msg "Uncompress the file......"
         uncompress $i
         new_file_name=`echo $i | awk -F ".Z" '{print $1 }'`
         print_msg "Encrypt the file"
         encrypt_file "$USER" $SRC_DIR $new_file_name
         return_val=$?
         if [ $return_val -eq 0 ]; then
            print_msg "Encryption Successful"
         else
            print_msg "Fail to encrypt"
            compress -f $SRC_DIR/$new_file_name || fn_ErrorExit "Problem while compressing sthe file"
            exit 1
         fi

      else
         print_msg "Bad extension for the file. Please check"

      fi
   done

elif [ $ENCRYPTION = "N" ] || [ $ENCRYPTION = "n" ] ; then
   print_msg "File encryption not require for the below files"
   cat $local_tmp_file | awk '{print "... " $2}'

else
   print_msg "Invalid Mode. Re-Execute with correct encryption option - Y/y/N/n"
   exit 1;

fi

# Moving files to destination directory
if [ $SRC_DIR = $DEST_DIR  ] ; then
   print_msg "Source and Destination Directory is same"
else
   print_msg "Moving all input files from $SRC_DIR to destination directory : $DEST_DIR"
   cd $DEST_DIR  || fn_ErrorExit "Problem while changing directory to destination directory"
   mv $SRC_DIR/${FILE_PATTERN}* $DEST_DIR
   chmod 644 ${FILE_PATTERN}*
   echo ".........."
   echo "........"
   echo "......"
   print_msg "Moved Successfully"
fi


rm -f $local_tmp_file
print_msg ".............................Processing Completed................................"
