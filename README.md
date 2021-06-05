# IN616_operating_systems
***
Author: Sam Winton  
Student code: wintst1  
Laste changes made: 2:23PM   
***

# Task 1: Usercreation Summary 

The Usercreation script ingests a csv file containing helpful user informaiton to create a user enviroment, ie: email addresses, dob, secondary groups, and/or shared folder.
A list of users is generated, then the script generates a username, password, groups if specified or not, shared folder if specified or not and a shutdown alais if the user 
is in the "sudo" group. The script automates the usercreation process, and can create many users all at once elminating tedious enviroment setup for the system admin. Users 
are required to change their password upon first login. 

### Pre-requisites

A csv file is required to be ingested into the script, then the script can run. If a csv file is not specified as an argument, then the script prompts the user for a csv file. 
The format of the csv file is as follows:  

EMAIL,YYYY/MM/DD,GROUPS,SHAREDFOLDER  
email.example@gmail.com,1999/09/26,Staff,/StaffFolder  

Note that the feild delimeter (,) can be a character of your choice, as the script asks you to specifiy what feild seperator your file uses.  

### Running the script  

The script can take in an argument provided through the command line. It is best if you run the script as sudo, to make sure all commands written in the script are executed properly. To run the script, make sure you are in the same directory as it and type in the following into your command line:  

sudo bash task_1_usercration.sh **your csv file name here**

if no file is specified, you will be prompted by the script to enter one when in it executed.  

Please enter a readable csv file or enter a url:  
    [1]: Press 1 to enter a csv file  
    [2]: Press 2 to insert a url  
    
The script can also download a csv file provided by a url.  

### Username and password generation  

After a file has been ingested by the script, the script will read the contents of that file and genrates the usernames and passwords from the provided file. The username for a user is generated from the first letter of the email and the surname. if an email is as follows: john.smith@gmail.com then the username will be jsmith.  

The password is generated from the users date of birth, which is the month and year appended together. if the user has a birthdate of 1999/09/28 then the password will be 091999. When the user logs in for the first time, they will be prompted to change their default password to something more secure.  

### Creating The Enviroment And Defaults 

After a file has been ingested, a list of the users account that are ready to be created will be displayed on screen. Please review the list and make sure the user details are correct. The user be asked for confirmation before the enviroments are created. If no group or shared folder is specified for the user, then the script automatically creates the secondary group "default", the shared folder "/shareddefault", assigns the user to the default group and creates a symbolic link within the users home directory. The script will create the enviroments after confirmation and will notify the user of any errors. Once the user enviroments are successfully created, the script will exit.  

***  
# Task 2: Directory Backup  

The backup script takes in a directory path provided through the command line or by input. The directory is copied and compressed into a gunzip file with all the file contents within that directroy compressed within the file. The user can choose to name the file with whatever they want. Once the directory is compressed the script will ask the user for details for the SCP protocol command which will transfer the compressed file to another machine.

### Pre-requisites

The backup script requires a full path to a target directory you wish to compress. A **full path** to a directory should be provided to the script, for example: /home/student/documents is a valid path but /student/documents is not. A remote machine is also required to transfer the compressed archive to, and knowledge of the remote machine's IP address, username, and directory structure should be known. The remote machine should also be set up to allow file transfer via SCP.  

### Running the Script

The script can take in an argument provided through the command line. It is best if you run the script as sudo, to make sure all commands written in the script are executed properly. To run the script, make sure you are in the same directory as it and type in the following into your command line:  

sudo bash task_2_backup.sh **your file path here**

if no file path is specified, you will be prompted by the script to enter one when in it executed.  

### Filling out details 

The user will be prompted to name their archive file, once named .tar.gz will be appended to the archive and the directory will be compressed into the named gunzip file. Next, the user will be prompted for the IP address, port number, username, and directory path of the remote machine. A summary of all the informaiton provided will be displayed for confimation and the user will be asked if they would like to proceed. 


