#! /usr/bin/bash 

#function to validate the input 
function validate_DB_name() {
  
  local DB_name=$1
	
	# if the user entered a name that exceedes the maximum allowed characters
  if [ ${#DB_name} -gt 64 ]
  then 
    echo 'Databse name exceed maximum allowed length.'
    echo 'Please enter a name less than 64 charcters.'
    return 0
  fi

	# if the user entered an empty string 
  if [ -z $DB_name ]
	then
    echo "Empty value. Database name must be at least one character."
    return 0
  fi

	# if the user entered a space in the name
	if [[ $DB_name =~ [[:space:]] ]]
	then
  		echo "Database name can not contain spaces."
      return 0
	fi

	# if the user entered a name which starts with a number 
	if [ $DB_name =~ ^[0-9] ]
  then
        echo "Invalid name: Cannot start with a number."
        return 0
  fi
	
	# if the user entered an unallowed charcter: ! @ # $ % ^ & * [ ] ( ) .
	if [ $DB_name =~ [^A-Za-z0-9_] ]
  then
        echo "Invalid name: Cannot contain special characters."
        return 0
  fi

	# if the user entered a name which starts with underscore _
	if [ $DB_name = ^_ ]
	then
  		echo "Invalid name: Cannot start with an underscore."
      return 0
	fi

	# if the user entered a reserved key word in the SQL language
  # declaring an array to store the reserved keywords in the SQL 
  reserved_keywords=(
    ABSOLUTE ACTION ADD ALL ALTER ANALYZE AND AS ASC ASSERTION AT AUTHORIZATION BACKUP BEGIN BETWEEN BY CASE CAST
    CHECK COLLATE COLUMN COMMIT COMPUTE CONNECT CONSTRAINT CONTAINMENT CONTINUE CORRESPONDING CREATE CROSS CUBE CURRENT
    CURRENT_DATE CURRENT_TIME CURRENT_TIMESTAMP CURRENT_USER DATABASE DATE DAY DEALLOCATE DECLARE DEFAULT DEFER DELETE DESC
    DESCRIBE DIAGNOSTICS DISCONNECT DISTINCT DO DOMAIN DROP DYNAMIC ELSE END ESCAPE EXCEPT EXECUTE EXISTS EXPLAIN EXTEND
    FALSE FETCH FILTER FIRST FLOAT FOR FOREIGN FROM FULL FUNCTION GENERAL GLOBAL GRANT GROUP HAVING HOLD IDENTITY IF
    IMMEDIATE IN INDICATOR INHERIT INOUT INSENSITIVE INSERT INTERSECT INTERVAL INTO IS ISOLATION JOIN KEY LANGUAGE LATERAL
    LEADING LEFT LIKE LIMIT LOCAL MATCH MAXVALUE MEMBER MERGE MINVALUE MODIFY MODULE MONTH NATURAL NO NOT NULL NUMERIC OF
    OFF OLD ON ONLY OPEN OPERATOR OPTION OR ORDER OUT OUTER OVER PARAMETER PARTITION PASCAL PLACING PRECISION PREPARE PRIMARY
    PRINT PROCEDURE PUBLIC READ REAL REASSIGN RECHECK RECOMPILE REF REFERENCES REGRANT RELATIVE RELEASE RENAME REPEAT REPLACE
    REQUIRE RESPECT RESTRICT RETURN REVOKE RIGHT ROLE ROW ROWS SAVEPOINT SCHEMA SECOND SECTION SELECT SENSITIVE SEQUENCE
    SERIALIZABLE SESSION SET SIZE SMALLINT SOME SPECIFIC SQL SQLCODE SQLERROR SQLSTATE START STATIC STATISTICS SUBCLASS
    SUBPARTITION SUM SYNONYM SYSTEM TABLE TABLESAMPLE TEMP TEMPORARY THAN THEN TIME TIMESTAMP TO TRIGGER TRUE TRUNCATE TYPED
    UNION UNIQUE UNLISTEN UNPIVOT UPDATE USAGE USER USING VALUE VALUES VARCHAR VIEW WHEN WHERE WITH WORK WRITE XML)
  
  # Initialize a flag to check if the element is found
  declare -i found_flag=0

  # Iterate over the array
  for keyword in "${reserved_keywords[@]}"
  do
      if [ "$keyword" == "$DB_name^^" ]
      then
          found_flag=1
          break
      fi
  done

  # Check the flag if it equal to 1 ---> print error 
  if [ $found_flag -eq 1 ]
  then
      echo "Database name cannot be an SQL keyword."
      return 0
  fi

return 1 
}

#function to create data base

function create_DB(){
    read -p "Enter the name of the database: " DB_name
    # check if there is an existing DB with the same name
    if [ -d "${DB_name^^}" ]
    then 
      echo "This database already exists."
    else
        if [ validate_DB_name() $DB_name ]
        then 
          mkdir ${DB_name^^}
          echo "Database ($DB_name)created."
        fi
    fi
}		


#function to rename an existing Database
function rename_DB(){
	#Prompt the user to enter the current name of database
	read -p "Please enter the name of database you want to rename:" DB_name
	# todo --> make the name (case-insenstive)
	if [ -d ${DB_name^^} ]
	then	
	while true
	do
		read -p "Please enter the new name: " DB_new_name 
		if [ validate_name ${DB_new_name^^} ]
		then 
			mv $DB_name ${DB_new_name^^}
			break
		else
			echo "Invalid name"
			read -p "return to main menu press (x) to re-enter the name press any key: " confirm
			if [ ${confirm^^} = "X" ]
				break
			fi
		fi 
	done
	fi
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
	if [ -d  ${DB_name^^} ]
	then
		#validate if the database(dir) contains tables(files) to warn the user
		if [ `ls -A $1` ] # return true if there are files in the directory
		then 
			echo "The Database contains Data"
			read -p "Are you sure you want to DROP Data Base? (y/n)? " confirm_drop
			
			if [ "YES" =~  ${confirm_drop^^} ]
			then 
				# f to force delete the content of directory without re-warn the user
				rm -rf $1
				echo "Database ($DB_name) deleted"
				return 0
			elif  [ "NO" =~  ${confirm_drop^^} ]
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
	read -p "Please enter DB name you want to connect" DB_name

	
	# Validate that the database name exists in the DBMS
	if [ -d  ${DB_name^^} ]
	then
		cd ${DB_name^^}
		echo "You are now in the ($DB_name) Database"
		#calling script  "db_script.sh" to manage tables.
		.././db_script.sh
		return 0
	#if there is no database with the entered file
	else 
		echo "No Database with name ($DB_name) existing"
		return 1
  fi
}




echo "Enter the option you want"

select option in "Create Database" "List Databases" "Delete Database" "Connect to Database" "Exit"
do
    case $option in
        "Create Database")
            create_DB
            ;;
        "List Databases")
            list_DB
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
