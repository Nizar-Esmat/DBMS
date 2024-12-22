
clear
function validate_DB_name() {
    local DB_name=$1

    # Check if the name exceeds the maximum allowed characters
    if [ ${#DB_name} -gt 64 ]; then
        echo 'Database name exceeds maximum allowed length.'
        echo 'Please enter a name less than 64 characters.'
        return 1
    fi

    # Check if the name is empty
    if [ -z "$DB_name" ]; then
        echo "Empty value. Database name must be at least one character."
        return 1
    fi

    # Check if the name contains spaces
    if [[ $DB_name =~ [[:space:]] ]]; then
        echo "Database name cannot contain spaces."
        return 1
    fi

    # Check if the name starts with a number
    if [[ $DB_name =~ ^[0-9] ]]; then
        echo "Invalid name: Cannot start with a number."
        return 1
    fi

    # Check if the name contains special characters
    if [[ $DB_name =~ [^A-Za-z0-9_] ]]; then
        echo "Invalid name: Cannot contain special characters."
        return 1
    fi

    # Check if the name starts with an underscore
    if [[ $DB_name =~ ^_ ]]; then
        echo "Invalid name: Cannot start with an underscore."
        return 1
    fi

    # Check if the name is an SQL reserved keyword
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
        UNION UNIQUE UNLISTEN UNPIVOT UPDATE USAGE USER USING VALUE VALUES VARCHAR VIEW WHEN WHERE WITH WORK WRITE XML
    )

    for keyword in "${reserved_keywords[@]}"; do
        if [[ "${DB_name^^}" == "$keyword" ]]; then
            echo "Database name cannot be an SQL keyword."
            return 1
        fi
    done

    # If all checks pass, the name is valid
    return 0
}

#function to create data base

function create_DB(){
    read -p "Enter the name of the database: " DB_name
    # Check if there is an existing DB with the same name
    if [ -d "${DB_name^^}" ]; then 
        echo "This database already exists."
    else
        # Call validate_DB_name function and check its return value
        if validate_DB_name "${DB_name}"; then 
            mkdir "${DB_name^^}"
            echo "Database ($DB_name) created."
        else
            echo "Invalid database name."
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
		if [ validate_name ${DB_new_name^^} ];
		then 
			mv $DB_name ${DB_new_name^^}
			break
		else
			echo "Invalid name"
			read -p "return to main menu press (x) to re-enter the name press any key: " confirm
			if [ ${confirm^^} = "X" ];
      then
				break
			fi
		fi 
	done
	fi
}


function list_DB() {
    # Check if there are any directories
    if [ "$(ls -d */ 2>/dev/null)" ]; then
        for dir in */; do
            echo "${dir%/}" 
        done
    else
        echo "No databases found."
    fi
}


function drop_DB() {
    # Prompt the user to enter the database name
    read -p "Please enter the database name you want to DROP: " DB_name

    # Validate that the database name exists in the DBMS
    if [ -d "${DB_name^^}" ]; then
        # Validate if the database (directory) contains tables (files)
        if [ "$(ls -A "${DB_name^^}" 2>/dev/null)" ]; then
            echo "The Database contains data."
            read -p "Are you sure you want to DROP the database? (y/n): " confirm_drop

            if [[ "${confirm_drop^^}" =~ ^Y ]]; then
                # Force delete the directory and its contents
                rm -rf "${DB_name^^}"
                echo "Database ($DB_name) deleted."
                return 0
            elif [[ "${confirm_drop^^}" =~ ^N ]]; then
                echo "Database ($DB_name) wasn't deleted."
                return 1
            else
                echo "Invalid answer. Please respond with 'y' or 'n'."
                return 2
            fi
        else
            # If the database (directory) doesn't contain any tables (files)
            rm -rf "${DB_name^^}"
            echo "Database ($DB_name) deleted."
            return 0
        fi
    else
        echo "Database ($DB_name) does not exist."
        return 3
    fi
}


# This function connects the user to a Database in the DBMS
function connect_to_DB(){
	#first, prompt the user to enter the database name (directory)
	read -p "Please enter DB name you want to connect : " DB_name

	
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
