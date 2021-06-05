#!/bin/bash

#################################################################################################
# Sam Winton											#
# Task 2: Compression And Backup								#
# Description:											#
# this script asks the user for a directory, I thnk the full path to the directory has to be 	#
# specified. It then compresses the file, adding the .tar.gz extension to the name, then 	#
# asks for deatils on transfering the compressed directory with all its contents to another	#
# machine.											#
#################################################################################################




RED='\033[0;31m'
NC='\033[0m'

#this function handles the scp tranfer command. asks the user for a bunch of informaton like the host address,
#also validates the input to make sure the user only enters in 1 argument and asks the user to review the 
#informaiton they provided before moving on. 
transfer() {
	echo "File name: $1, Directory to be encrypted: $2"
	echo "Are you sure you wish to proceed? [Y/N]"
	read response

	case "$response" in
        	[yY][eE][sS]|[yY])  
	        clear
        	;;
        	*)
	        echo "Exiting script..."
        	exit 0
	        ;;
	esac

	echo -n "Please enter the IP address of the remote host: "
	read ipaddr extra; clear

	if [ -n "$extra" ]; then
                echo "Error! Please insert only one ip address!"
                exit 0
	elif [ -z "${ipaddr// }" ]; then
                echo "Error! ipaddress required!"
                exit 0
        fi


	echo -n "Please enter the Port number of the remote host: "
	read portnum extra; clear 

	if [ -n "$extra" ]; then
                echo "Error! Please insert only one port number!"
                exit 0
	 elif [ -z "${portnum// }" ]; then
                echo "Error! port number required!"
                exit 0

        fi


	echo -n "Please enter the directory that you wish the file to be stored in on the remote host: "
	read remotedir extra; clear

        if [ -n "$extra" ]; then
                echo "Error! Please insert only one directory!"
                exit 0
         elif [ -z "${remotedir// }" ]; then
                echo "Error! directory required!"
                exit 0
        fi


	echo -n "Please enter the username of the remote host: "
	read username extra; clear 

        if [ -n "$extra" ]; then
                echo "Error! Please insert only one username!"
                exit 0
         elif [ -z "${username// }" ]; then
                echo "Error! username required!"
                exit 0
        fi

	echo "=============================================================="
	echo "Confriming details, please read carefully before proceeding..."
	echo "=============================================================="
	echo -e "Directory: ${RED}$2${NC}"
	echo -e	"File: ${RED}$1${NC}"
	echo -e	"Remote host: ${RED}$ipaddr${NC}"
	echo -e	"Port num: ${RED}$portnum${NC}"
	echo -e "Target directory: ${RED}$remotedir${NC}"
	echo -e	"Host username: ${RED}$username${NC}"
	
	echo -e "\nAre you sure you wish to proceed? [Y/N]"
        read response

        case "$response" in
                [yY][eE][sS]|[yY])
                echo "transferring $1 to $username..."
                ;;
                *)
                echo "Exiting script..."
                exit 0
                ;;
        esac
 
	sudo scp -P $portnum $1 $username@$ipaddr:"$remotedir"

	#unsure if these exit status codes are the actual ones that the scp command uses,
	#at lesat I know that 0 is sucessful, anything else is an error. 
	if [ $? -eq 0 ]; then 
		echo "Sucess! File transfer completed"
		exit 0
	elif [ $? -eq 74 ]; then
		echo "Error! Conneciton lost, exiting..."
		exit 0
	elif [ $? -eq 79 ]; then 
		echo "Error! Invalid username, exiting..."
		exit 0
	elif [ $? -eq 2 ]; then 
		echo "Error! Destination is not a directory, exiting..."
		exit 0 
	else
		echo "Erorr encountered! Exiting..."
	fi

}


#the below function compresses the directory into a tarball archive with some basic error checking 
#in place, then calls the transfer function to run the scp command. 
tarball() {
	echo "You've Selected $dirname as Your Directory. Press Enter to Continue..."
	read; clear

	echo "Preparing Compression..."
	echo -n "Name your gzip file: "
	read gzip extra; clear 
	
	if [ -n "$extra" ]; then 
                echo "Error! Please insert only one filename!"
                exit 0
	elif [ -z "${gzip// }" ]; then 
		echo "Error! File cannot have no name!"
		exit 0
        fi

	#appened .tar.gz to the filename
	gzip+=".tar.gz" 

	echo "Beginning compression..." 	
	tar -cvzf $gzip $dirname   
	
	if [ $? -eq 0 ]; then
		echo "Sucess, directory compressed!"
		transfer $gzip $dirname
	else 
		echo "Error! Something went wrong, exiting..."
		exit 0
	fi 
}

#handles userinput, the user can only enter in one directory, below contains a bunch 
#of statements to validate the input, eg: checking if the directory exists, making 
#sure there is only 1 arguemnt entered into the script, if the conditions are met
#then the function tarball is called. 

if [ $# -eq 0 ]; then 
	echo -n "Please enter the fullpath to a directory: "
        read dirname extra 

	if [ -n "$extra" ]; then 
		echo "Error! Please insert only one directory!"
		exit 0
	elif [ -z "${dirname// }" ]; then
		echo "Error! Directory cannot be nothing!"
		exit 0 
	fi 

elif [ $# -eq 1 ]; then
	dirname=$1 
else 
	echo "Error! Input can only take in 1 arugment! Exiting..."
	exit 0 
fi  

if [ -d "$dirname" ]; then
	tarball $dirname
else
	echo "Error! Directory does not exist! Exiting..."
	exit 0
fi
