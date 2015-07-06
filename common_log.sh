#!/bin/sh
##################################################################################
# FILE NAME             : common_log.sh
# PURPOSE               : Encrypt the input file, depending on parameter
# CREATED BY            : Murari Goswami
# DESCRIPTION           : It contains the common utility functions for
#                          1. Generate error/process logs
#			               2. Raise traps and emails to OPS as singleton functions
#               		   3. fn_ErrorExit
#               		   4. check_string
#              			   5. check_number
#              			   6. check_param_count
#               		   7. check_conn_error
#               		   8. encrypt_file
#               		   9. decrypt_file
##################################################################################

# Declaration of local variable


dt=`date +"%d%m%Y%H%M%S"`  # Capture the current date in pictorial format
                           # with time stamp of execution
incr=0                     
curr_dt=`date +"%m/%d/%Y"`
gpg_path=/usr/local/bin

#=======================================================
# Function PRINT_MSG - to print messages to log
#=======================================================
print_msg ()
{
    date +"%Y/%m/%d %H:%M:%S : $1"
}

#=======================================================
# Function addone - to add counter value
#=======================================================
addone()
{
   incr=`expr $incr + 1`
}

#======================================================================
# Function ERROR_MSG - to print error messages and exit the processing
#======================================================================
error_msg ()
{
    print_msg "ERROR: $1"
    print_msg "Exiting ..."
    ops_email "$1" "$2" "$3"
    exit 1
}


#=====================================================================
# Function ERROR_TAG - to rename the file with error suffix
#=====================================================================
error_tag ()
{
    print_msg "ERROR: $1"
    print_msg "Renaming the file with error suffix ..."
    mv -f ${data_file} ${data_file}.error 2>/dev/null
    print_msg "Exiting ..."
    exit 1
}


#=====================================================================
# Function OPS_EMAIL - to send email to Opeartions
#=====================================================================
ops_email ()
{

  print_msg "Sending email to $3"
  echo "$1" | mailx -s "$2" "$3"
}

#=============================================================================
# Function CONN_CHECK - to check for connectivity with remote servers
#=============================================================================
conn_check ()
{
 cat $2 | grep -ie "Not connected" -ie "Login failed"
 if [ $? -eq 0 ]
 then
    print_msg "FTP Connectivity issue with remote server $1"
    rm -f $2 || print_msg "File : $2 is missing"
    echo "Connection problem with $1" | mailx -s "FTP connectivity issue with $1 while trying to pull the file $3 " "$4"
    exit 1
 fi
}

#=============================================================================
# Function FN_ERROREXIT - to print error messages and exit the processing
#=============================================================================
fn_ErrorExit ()
{
   echo "There Has Been Problem $1"
   exit 1;
}


#=============================================================================
# Function CHECK_STRING - to check whether provided paramaeter contains any number
#=============================================================================
check_string()
{
   if echo "${1}" | grep '[0-9]' >/dev/null; then
      print_msg "Contains the numeric value"
      print_msg "Invalid input. Re-execute with correct input value"
      exit 1
   else
      print_msg "Validation Successful. Purely String"
   fi
}


#=============================================================================
# Function CHECK_NUMBER - to check whether provided paramaeter contains any alphabate
#=============================================================================
check_number()
{
   if [[ $1 = *[!0-9]* ]]; then
      print_msg " '$1' Contains the alphabate value"
      print_msg "Invalid input. Re-execute with correct input value"
      exit 1
   else
      print_msg "Validation Successful. Purely Numeric Value"
   fi
}

#=============================================================================
# Function CHECK_PARAM_COUNT - to check whether provided paramaeter count is correct
#=============================================================================
check_param_count()
{
   if [ $1 != $2 ] ; then
      print_msg "Total number of parameters passed to the script is not equal to $1."
      print_msg "Please re-execute with correct number of parameters"
      exit 1;
   else
      print_msg "Validation for Parameter Count - Successful"
   fi
}

#=============================================================================
# Function CHECK_CONN_ERROR - to check for any error while sending file to remote server
#=============================================================================
check_conn_error()
{
   cat $2 | grep -ie "Not connected" -ie "Login failed"
   if [ $? -eq 0 ]
   then
      print_msg "There is connectity issue with $1 server."
      print_msg "Please confirm for connectity and re-execute."
      exit 1
   else
      cat $2 | grep -ie "No such file or directory"
      if [ $? -eq 0 ]
      then
         print_msg "Given remote directory does not exists"
         print_msg "Please check remote directory name"
         exit 1
      else
         print_msg "All remote server parameters are correct"
      fi
   fi

}

#=============================================================================
# Function ENCRYPT_FILE - to encrypt the given source file
#=============================================================================
encrypt_file()
{
   print_msg "Start Encryption"
   /usr/local/bin/gpg --no-greeting --no-secmem-warning --encrypt --batch -r "$1" $2/$3
   if [ $? -eq 0 ]
   then
      return 0
   else
      return 1
   fi

}

#=============================================================================
# Function DECRYPT_FILE - to decrypt the source file
#=============================================================================
decrypt_file()
{
   print_msg "Start Decryption"
   PASSPHRASE=$1
   OUT_FILE=$2
   SCR_FILE=$3
   SCR_DIR=$4

   echo "${PASSPHRASE}" | /usr/local/bin/gpg --no-greeting --no-secmem-warning --passphrase-fd 0 --batch -d --output ${SCR_DIR}/${OUT_FILE} ${SCR_DIR}/${SCR_FILE}
   if [ $? -eq 0 ]
   then
      return 0
   else
      return 1
   fi
}
