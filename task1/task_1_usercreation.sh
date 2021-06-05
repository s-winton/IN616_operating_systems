#!/bin/bash

#################################################################################################
# Sam Winton 											#
# Task 1: usercreation script 									#
# Notes: 											#
# Please run the script as sudo, as the alias command doesn't work unless it is ran as sudo,    #
# however when I added sudo to the line, it created a file named "sudo" and outputted the       #
# alias into that file instead of the created users .bashrc, I have no idea how to run the 	#
# command without that problem happening as without sudo permission gets denied. 	        #
#												#
# No logging of the script has been done since I'm not sure how to log everthing, and only 1    #
# secondary group can be specified in the csv file as I couldn't figure out how to add 2 or     #
# more secondary groups if specified within the csv folder.  					#
#################################################################################################


#checks if the shared folder exists, if not then creates the folder in the /home directory
#and change permissions to the folder to only be acessed by users of the shared group
#also checks if a folder has been specified, if not then creates the default shared folder
#and chekcs what group the user is in before altering permissions.
createFolder(){
if [ -z "${folder[$i]}" ]; then
	echo "no shared folder specified for ${username[$i]}, creating folder: /sharedDefault"
        sudo mkdir /home/sharedDefault 2> /dev/null

                if [ $? -eq 0 ]; then
                        echo "folder: /sharedDefault created"

                elif [ -z ${group[$i]} ]; then
                        sudo chgrp -R default /home/sharedDefault
                        sudo chmod -R 2775 /home/sharedDefault
                        sudo ln -s /home/sharedDefault /home/${username[$i]}
		        if [ $? -eq 0 ]; then
                		echo "symbolic link created!"
		        fi
                else
                        sudo chgrg -R ${group[$i]} /home/sharedDefault
                        sudo chmod -R 2775 /home/sharedDefault
                        sudo ln -s /home/sharedDefault /home/${username[$i]}
			if [ $? -eq 0 ]; then
				echo "symbolic link created!"
			fi
                fi

elif [ -d "/home${folder[$i]}" ]; then
        echo "shared folder ${folder[$i]} already exists"
        sudo chgrp -R ${group[$i]} /home${folder[$i]}
        sudo chmod -R 2775 /home${folder[$i]}
        sudo ln -s /home${folder[$i]} /home/${username[$i]}
        if [ $? -eq 0 ]; then
                echo "symbolic link created!"
        fi

else
        echo "creating shared folder ${folder[$i]}"
        sudo mkdir /home${folder[$i]}
        sudo chgrp -R ${group[$i]} /home${folder[$i]}
        sudo chmod -R 2775 /home${folder[$i]}
	sudo ln -s /home${folder[$i]} /home/${username[$i]}
	if [ $? -eq 0 ]; then 
		echo "symbolic link created!"
	fi
fi
}


#checks if the group exists, if not then creates the group, also checks if the group array has an empty
#string and if it does creates the default group, and assigns the user to that group.
#if the default group exists it just pipes the error message to /null
#so that the message doesn't appear in the commmand line
createGroup() {
if [ -z "${group[$i]}" ]; then
	echo "no group specified for ${username[$i]}, assigning to group: default"
        sudo groupadd default 2> /dev/null

        	if [ $? -eq 0 ]; then
                	echo "group: default created"
                	sudo usermod -a -G default ${username[$i]}
                	echo "added ${username[$i]} to default"
       	 	else
                	sudo usermod -a -G default ${username[$i]}
                	echo "added ${username[$i]} to default"
        	fi

elif grep -q ${group[$i]} /etc/group; then
        echo "group ${group[$i]} already exists"
        sudo usermod -a -G ${group[$i]} ${username[$i]}
        echo "added ${username[$i]} to ${group[$i]}"
else
	echo "creating group ${group[$i]}"
        sudo groupadd "${group[$i]}"
        sudo usermod -a -G ${group[$i]} ${username[$i]}
        echo "added ${username[$i]} to ${group[$i]}"
fi
}

#creates the user accounts, sets the default password and changes the password expiry so that
#the user needs to change their password on their first login.
createUser() {
if sudo grep -q ${username[$i]} /etc/passwd; then
        echo "user ${username[$i]} already exists"
else
        sudo useradd -d /home/${username[$i]} -m -s /bin/bash ${username[$i]}
        echo  ${username[$i]}:${password[$i]} | sudo chpasswd
	sudo chage -d0 ${username[$i]}
	echo "user: ${username[$i]} added"
fi
}


#displays otput to the user on what the script has done 
runLoop(){
for i  in "${!username[@]}"
do
	echo "=============================================================================="

        createUser
        createGroup
        createFolder

        #if user is in group sudo create the shutdown alias
        if [[ ${group[$i]} == *"sudo"* ]];then
                echo "alias SD='sudo shutdown -h now'" >> /home/${username[$i]}/.bashrc
		echo "created alias for ${username[$i]}"
        fi

        echo "=============================================================================="
done

}

showDetails(){
for i in "${!username[@]}"
        do
                echo "=============================="
                echo "Username: ${username[$i]}"
                echo "Password: ${password[$i]}"
                echo "Groups: ${group[$i]}"
                echo "Shared Folder: ${folder[$i]}"

                        if [[ ${group[$i]} == *"sudo"* ]];then
                                echo "Alias: SD"
                        fi

                echo "=============================="
        done
echo "$usercount users are ready to be created"
echo "Are you sure you wish to proceed? [Y/N]"
read response

case "$response" in
        [yY][eE][sS]|[yY])
        echo "creating users..."
        clear
	runLoop
        ;;
        *)
        echo "Exiting script..."
        exit 0
        ;;
esac
}

#reads the csv file, asks the user what feild delimeter they wish to use 
readFile() {
usercount=0
echo "Selected $file"
echo "press enter to continure"
read; clear

echo "Please specify your CSV feild delimeter: "
read delimeter extra; clear 

        if [ -n "${extra}" ]; then
                echo "Error! Please enter only one delimeter!"
                exit 0
	elif [ -z "${delimeter// }" ]; then
                echo "Error! delimeter cannot be empty!"
        	exit 0
	elif [[ "${#delimeter}" -gt 1 ]];then
		echo "Error! feild delimeter can only be 1 character!"
		exit 0
	fi



# in the provided csv file some lines had two groups seperaed by a ",". I wasn't sure how to 
# figure out how to add 2 secondary groups to a user if two groups were specified or how to seperate
# the group names, so the sciprt can only take in 1 secondary group for a user. 
 
while  IFS="${delimeter}" read -r email birthDate groups sharedFolder
	do 
		#creating arrays of groups, usernames, shared folder and passwords
		#adding first character of name to a string then extracting the 
		#surname and finally adding the 2 strings together to the username array	

		lastname=$(echo "$email" | sed 's/^[^.]*.//' | sed 's/@.*//')
		firstchar=${email:0:1}
		username+=("$firstchar$lastname")

		#extracting the strings needed for the password 
		month=$(echo "${birthDate:5}" | sed 's/[/].*//')
		year=$(echo "$birthDate" | sed 's/[/].*//')
		password+=("$month$year")

		group+=("$groups")     
		folder+=("$sharedFolder")
		
	let usercount++
	done < <(tail -n +2 $file)	
showDetails
}


#asking user for input and general error handling 		
clear
if [ $# -eq 0 ]; then
        echo "Please enter a readable csv file or enter a url: "
	echo "[1]: Press 1 to enter a csv file"
	echo "[2]: Press 2 to insert a url" 
	echo "Press any key to exit"
	read resp; clear 

	case "$resp" in 
		[1])
		echo "Please enter a redable csv file: " 
                read file extra; clear

                if [ -n "$extra" ]; then
                        echo "Error! Please insert only one file!"
                        exit 0
                elif [ -z "${file// }" ]; then
                        echo "Error! file required!"
                        exit 0
        	fi
		;;
		[2])
		echo "Please enter your url: "
		read url extra; clear
		sudo wget -O downloaded_users.csv  $url

		if [ $? -eq 0 ]; then 	
			file=downloaded_users.csv	
			echo "File downloaded and renamed to $file"
                elif [ -n "$extra" ]; then
                        echo "Error! Please insert only one file!"
                        exit 0
                elif [ -z "${url// }" ]; then
                        echo "Error! url required!"
                        exit 0
		else 
			echo "Error! Something went wrong, exiting..."
			exit 0
                fi 
		;;
		*)
		echo "Exiting script..."
		exit 0
		;;
	esac 

elif [ $# -eq 1 ]; then
	file=$1; clear  
else 
	echo "Error! Input can only be 1 file! Exiting.... "
	exit 0
fi

if [ ! -f $file ]; then 
	echo "Error: Cannot find file $file, Exiting...."
	exit 0
else
	readFile $file
fi
