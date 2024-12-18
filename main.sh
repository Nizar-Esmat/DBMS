#! /usr/bin/bash 


# This function deletes a Database from the DBMS
function drop_DB(){
	
	#first, prompt the user to enter the database name (directory)
	read -p "Please enter DB name you want to DROP" DB_name
	
	# Validate that the database name exists in the DBMS
	if [ -d  $DB_name ]
	then
		#validate if the database(dir) contains tables(files) to warn the user
		if [ `ls -A $1` ] # return true if there are files in the directory
		then 
			echo "The Database contains Data"
			read -p "Are you sure you want to DROP Data Base? (y/n)? " check_drop
			
			if [ "yes" =~  $check_drop ]
			then 
				# f to force delete the content of directory without re-warn the user
				rm -rf $1
				echo "Database ($DB_name) deleted"
				return 0
			elif  [ "no" =~  $check_drop ]
			then 
				echo "Database ($DB_name) wasn't deleted"
				return 1
			else 
				echo 'Invalid answer'
				return 2
			fi
		
		# if the database(dir) doesn't contain tables(files)
		else
			rm -rf $1
			echo "Database ($DB_name) deleted"
			return 0
		fi
	fi
}


# This function connects the user to a Database in the DBMS
function connect_DB(){
	#first, prompt the user to enter the database name (directory)
	read -p "Please enter DB name you want to DROP" DB_name
	
	# Validate that the database name exists in the DBMS
	if [ -d  $DB_name ]
	then
		cd $DB_name
		echo "You are now in the ($DB_name) Database"
		#calling script  "db_script.sh" to manage tables.
		. ./db_script.sh
		return 0
	#if there is no database with the entered file
	else 
	then 
		echo "No Database with name ($DB_name) existing"
		return 1
}




