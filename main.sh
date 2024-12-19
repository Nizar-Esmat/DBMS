<<<<<<< tarek
#! /usr/bin/bash 


#function to validate the input 
function validate_name() {
    local name=$1

    if [[ $name =~ ^[0-9] ]]; then
        echo "Invalid name: Cannot start with a number."
        return 0
    fi

    if [[ $name =~ [^A-Za-z0-9_] ]]; then
        echo "Invalid name: Cannot contain special characters."
        return 0
    fi

    return 1 
}





#function to create data base
clear
function create_DB(){
    read -p "Enter the name of the database: " DB_name

    validateName $DB_name
    validation_result=$?
    if (($validation_result)); then 
        if [[ ! -d "$DB_name" ]]; then 
            mkdir $DB_name
            echo "Database created."
        else 
            echo "This database already exists."
        fi
    else
        echo "You have an error."
    fi
}		


#function to rename an existing Database
function rename_DB() {
	
	#TO IMPLEMENT ---> Tarek



}


function list_DB() {
    # Loop over the directory names (Databases) to remove the last character (/)
    count=0
    for dir in `ls -d */`
    do
        echo "${dir%/}"
        count=$(($count + 1))
    done
    echo "The number of databases is $count."
}



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
function connect_to_DB(){
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




echo "Enter the option you want"

select option in "Create Database" "List Databases" "Delete Database" "Connect to Database" "Exit"
do
    case $option in
        "Create Database")
            createDB
            ;;
        "List Databases")
            listDB
            ;;
        "Delete Database")
            drop_DB
            ;;
        "Connect to Database")
            connect_to_DB
            ;;
        "Exit")
            read -p "Do you want to exit? (yes/no): " exit
            if [[  $exit =~ "yes" ]]; then
                echo "You exited the system."
                break
            elif [[ $exit =~ "no" ]]; then
                echo "You are still in the system. Choose an option."
                continue
            else
                echo "Invalid input."
            fi
            ;;
        *)
            echo "Invalid input. Please try again."
            ;;
    esac
done

>>>>>>> master
