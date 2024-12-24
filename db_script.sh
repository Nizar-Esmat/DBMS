#! /usr/bin/bash

# Functions that validates the name of a table
# Returns 1 if the table name is invalid, return 0 if the table name is valid
function validate_table_name() {
    local table_name=$1

    # Check if the table name exceeds the maximum allowed characters
    if [[ ${#table_name} -gt 64 ]]
	then
        echo "Invalid table name. Table name exceeds the maximum allowed length (64 characters)."
        return 1
    fi

    # Check if the table name is empty
    if [[ -z "$table_name" ]]
	then
        echo "Invalid table name. Table name must be at least one character."
        return 1
    fi

    # Check if the table name contains spaces
    if [[ $table_name == " " ]]
	then
        echo "Invalid table name. Table name cannot contain spaces."
        return 1
    fi

    # Check if the table name starts with a number
    if [[ $table_name =~ ^[0-9] ]]; then
        echo "Invalid table name. Table name cannot start with a number."
        return 1
    fi

	# Check if the table name starts with an underscore
    if [[ $table_name =~ ^[_] ]]
	then
        echo "Invalid table name. Table name cannot start with an underscore"
        return 1
    fi

	# Check if the table name starts with a (.)
    if [[ $table_name =~ ^[.] ]]
	then
        echo "Invalid table name. Table name cannot start with a period(.)"
        return 1
    fi

	# Check if the table name starts with (-)
    if [[ $table_name =~ ^[-] ]]
	then
        echo "Invalid table name. Table name cannot start with (-)"
        return 1
    fi
    
	# Check if the table name contains special characters other than underscore
    if [[ $table_name =~ [^A-Za-z0-9_.-] ]]; then
        echo "Invalid table name. Table name cannot contain special characters (except underscores)."
        return 1
    fi

    # Check if the table name matches any SQL reserved keywords
    reserved_keywords=(
        ABSOLUTE ACTION ADD ALL ALTER ANALYZE AND AS ASC ASSERTION AT ANY AUTHORIZATION BACKUP BEGIN BETWEEN BY CASE CAST
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

    for keyword in "${reserved_keywords[@]}"
	do
        if [[ "${table_name^^}" == "$keyword" ]]
		then
            echo "Invalid table name. Table name cannot be an SQL keyword."
            return 1
        fi
    done

    # Table name is valid
    return 0
}

#function to create a table(file) in the database(directory)
function create_table(){
	# Prompt the user to enter the name of the table
	read -p "Please enter the name of the table you want to create: " table_name
	
	# Check if the file already exists
	if [ -f ${table_name^^} ];
	then 
		echo "Table ($table_name) already exists"
	# if the table does't exist ---> validate the table name 
	else 
		# case(1): if the name entered is valid 
		if  validate_table_name $table_name
		then 
			
			# if the entered name is valid 
			# prompt the user for the number of columns
			read -p "Enter the number of columns: " column_numbers
			
			# make a flag for a table_primary key --> if it's 0 means we haven't choose a PK yet, if it's 1 means we already choosen a PK
			declare -i pk_flag=0

			# Loop to store data about each cloumn
			for ((i=0;i<$column_numbers;i++))
			do
				# metadata are stored for each column as follwing ---> pk:NAME:data_type
				# Variable (column_data) is to store name, data_type and PK(If exists) of each colun and store it in (.table.meta) hidden file 
				column_data=""
				#Prompt the user to enter the column name
				read -p "Enter column($(($i + 1))) name: " column_name
				# Check if the user entered a valid column_name
				if  validate_table_name $column_name;
				then
					column_data=$column_data":"${column_name^^}
				# If the user entered an invalid name ---> keep re-prompting for a valid name
				else 
					while true 
					do 
						# Reprompt the user to enter column_name
						read -p "Enter column($(($i + 1))) name: " column_name
						# If the user entered a valid name ---> break from the loop
						if  validate_table_name $column_name;
						then
							column_data=$column_data "" ":" "" ${column_name^^}
							break
						fi
					done
				fi
				
				# Prompt the user to enter the column datatype
				read -p "Enter column($(($i + 1))) datatype (int/str): " col_datatype
				# Check if the user entered a valid data_type
				if [ ${col_datatype^^} == "INT" -o $col_datatype == "INTGER" ];
				then 
					column_data+=":int"
				
				elif [ ${col_datatype^^} == "STR" -o $col_datatype == "STRING" ];
				then
					column_data+=":str"

				# If the user entered an invalid datatype ---> keep re-prompting for a valid datatype
				else 
					while true 
					do
						echo 'You entered an invalid datatype. Allowed datatypes are strings & intgers'
						read -p "Please enter (str) to store strings and (int) to store intgers" col_datatype
						# if the user entered a valid datatype break from the loop
						if [ ${col_datatype^^} = "INT" -o ${col_datatype^^} = "INTEGER" ];
						then 
							column_data+=":int"
							break
						elif [ ${col_datatype^^} = "STR" -o ${col_datatype^^} = "STRING" ];
						then
							column_data+=":str"
							break
						fi
					done	
				fi
				
				# prompt the user for a decision about primary key 
				# ---> if there is no Primary key choosen yet 
				if [ $pk_flag -eq 0 ]
				then
					read -p "Do you want column($column_name) to be set as primary key? (y/n): " PK
					while true 
					do
						# if the user entered y / yes
						if [ ${PK^^} = "Y" -o ${PK^^} = "YES" ]
						then 
							# Change (pk_flag) status to be 1 ---> so no other column set to be PK
							pk_flag=1
							column_data="pk$column_data"  # the final form of the meta_data about column ---> PK:COLUMN_NAME:column_data_type
							break
						
						# if the user entered no / n
						elif [ ${PK^^} = "N" -o ${PK^^} = "NO" ]
						then
							column_data="npk:" "" $column_data # the final form of the meta_data about column ---> npk:COLUMN_NAME:column_data_type
							break

						# if the user entered an invalid option
						else
							echo "Invalid option." 
							read "Enter (y) to set column($column_name) to be a Primay Key, Enter(n) otherwise" PK
						fi
					done 

				# ---> if there is a choosen Primary key
				else 
					column_data="npk"""$column_data   # the final form of the meta_data about column ---> npk:COLUMN_NAME:column_data_type
				fi

				
				# Append the column metadata to the table_meta_data file (it will be created for the first time when appending the first column_data)
				echo $column_data >> .${table_name^^}.metadata
			done
			# make a file to store the table's data
			touch ${table_name^^}
			echo "Table ($table_name) created sucssesfuly"

		fi	
	fi
}

#function to rename an existing table in the DB
function rename_table() {
	
	# check if no tables exists in the DB ---> echo "no tables to be renamed in this database" and return to main menu
	if [ -z "$(ls -A ./)" ]
	then 
		echo "There are no tables to rename in this database. You can create table instead!"	
		return
	fi

	# preview the tables to the user to choose a table to rename
	list_tables

	# If there is table/s in the DB ---> Prompt the user to enter the current name of table
	read -p "Please enter the name of table you want to rename:" table_name
	if [ -f ${table_name^^} ]
	then	
		while true
		do
			read -p "Please enter the new name: " table_new_name 
			if  validate_table_name $table_new_name  
			then 
			if [[ $table_new_name == $table_name ]]; then 
   				 echo "The new name is the same"
  				  return 0
			fi

				echo "this table changed to be $table_new_name "
				mv ${table_name^^} ${table_new_name^^}
				mv ".${table_name^^}.metadata" ".${table_new_name^^}.metadata" 
				break
			else
				echo "Invalid name."
				read -p "To re-enter the new table name press any key. To return to main menu press(x): " confirm
				if [ $confirm = "x" -o  $confirm = "X" ]
				then
					break
				fi
			fi 
		done
	fi
}

#function to list table names in a database
function list_tables(){
	declare -i count=0
	echo "-----------------------------------"
	echo "Tables excisting in the database:"
	echo "-----------------------------------"
    for file in `ls -h | grep -v '^d'`
    do
        echo $file
		count=$count+1
    done
	test $count -gt 0 && echo "-----------------------------------"
	if [[ $count -eq 0 ]];
	then
		echo "there is no tables in this database"
		echo "-----------------------------------"
	fi
	
}

#function to add records to a table
function insert_into(){
		# local table_name=${1^^}
		# echo $table_name

		# check if no tables exists in the DB ---> echo "no tables to be renamed in this database" and return to main menu
		if [ -z "$(ls ./)" ]
		then 
			echo "There are no tables to rename in this database. You can create table instead!"	
			return
		fi

		# if there is table/s in the database prompt the user to enter the table name 
		read -p "Please enter the name of the Table you want to insert into: " table_name
	table_name=${table_name^^}
		if [ -f $table_name ]
		then
			if [[ $# > 1 ]]
			then 
			echo "you must enter the table name only";
			echo $#
				return 0
			fi
						echo "you enter table $1"
							name=()
							type=()
							pk=""
					

							while IFS=':' read -r field1 field2 field3
				do
				#get the pramiry key from meta file
				if [[ "$field1" == "pk" ]]
				then 
				pk="$field2"
				fi
				name+=("${field2^^}")
				type+=("$field3")
							done < .${table_name}.metadata


					declare -A freq_array

					while IFS='|' read -r field1 _;  do
					
					if [[ -n "$field1" ]]; then
					freq_array["$field1"]=$(( ${freq_array["$field1"]} + 1 ))
					fi
					done < ./${table_name}

					new_data=""
					pk_flag=0
				for i in "${!name[@]}"; do
					is_pk=$([[ "${name[$i]}" = "$pk" ]] && echo 1 || echo 0)

				if [[ $is_pk -eq 1 ]]; then
					read -p "Enter the new data for ${name[$i]} of type (${type[$i]}) (this is a primary key) : " dt
				else
					read -p "Enter the new data for ${name[$i]} of type (${type[$i]}): " dt
				fi

	if [[ -z $dt && -z $s_pk ]]; then
		echo "Input is empty. Assigning 'null'."
		dt="null"
	elif [[ ${type[$i]} =~ "int" && ! $dt =~ ^[0-9]+$ ]]; then
		echo "Error: Not a number."
		return 0
	elif [[ ${type[$i]} =~ "str" && ! $dt =~ ^[A-Za-z_]+$ ]]; then
		echo "Error: String cannot contain numbers or special characters."
		return 0
	fi




  			  if [[ $is_pk -eq 1 ]]; then
    	  	    if [[ ${freq_array[$dt]} -ge 1 ]]; then
    		        echo "The primary key cannot be duplicate."
    		        return 0
     		   else
       			     freq_array["$dt"]=$(( ${freq_array["$dt"]} + 1 ))
      			  fi
  			  fi


  				if [[ -z $dt ]]
				then
					echo "Input is empty. Assigning 'null'."
					dt="null"
				elif [[ ${type[$i]} =~ "int" && ! $dt =~ ^[0-9]+$ ]]
				then
					echo "Error: Not a number."
					return 0
				elif [[ ${type[$i]} =~ "str" && ! $dt =~ ^[A-Za-z_]+$ ]]
				then
					echo "Error: String cannot contain numbers or special characters."
				return 0
				

		
    	fi
    # Append data to the `new_data` variable
    if [[ $i -ne 0 ]]
    then
        new_data+="|$dt"
    else
        new_data+="$dt"
    fi
  done			
			echo $new_data >> $table_name
	else
    echo "This table does not exist."
	fi

}

# data age=10 where name=Nizar
function update_table(){
		table_name=${1^^}

		# Check if the table exists
		if [[ ! -f $table_name ]]; then
			echo "This table does not exist."
			return 1
		fi

		# Check if the table is empty
	if [[ ! -s $table_name ]]; then
	echo "The table is empty."
	return 1
	fi

	if [[ $# -eq 4 ]]; then
		# where
		check=$3
		if [[ $check =~ [[:space:]]*[Ww][Hh][Ee][Rr][Ee][[:space:]]* ]]; then
			condtion_to_change=$2
			special_char=$(echo "$condtion_to_change" | grep -o '[=]')
			if [[ $special_char =~ ^[=] ]]; then 
				column_to_change=$(echo "$condtion_to_change" | awk -F= '{print $1}')
				column_to_change=${column_to_change^^}
				data_to_change=$(echo "$condtion_to_change" | awk -F= '{print $2}')
			else
				echo "Enter a valid data"
			fi

			valid_column_to_change=$(awk -F: -v column_to_change="$column_to_change" ' 
				$2 == column_to_change { print NR; exit }
				' ".${table_name}.metadata")

			is_pk=$(awk -F: -v column_to_change="$column_to_change" '
				$1 == "pk" && $2 == column_to_change {print 1; exit}
				' ".${table_name}.metadata")

			if [[ ! $valid_column_to_change ]]; then
				echo "There is no column with this name"
				return 0
			fi

			# name=Nizar
			condtion_to_check=$4
		special_char_to_check=$(echo "$condtion_to_check" | grep -o '[=]')
	if [[ $special_char_to_check =~ ^['='] ]]; then 
		column_to_check=$(echo "$condtion_to_check" | awk -F'[=]' '{print $1}')
		column_to_check=${column_to_check^^}  # Convert to uppercase
		data_to_check=$(echo "$condtion_to_check" | awk -F'[=]' '{print $2}')
	else
		echo "Enter a correct condition to check"
		return 0
	fi

	valid_column_to_check=$(awk -F: -v column_to_check="$column_to_check" ' 
		$2 == column_to_check { print NR; exit }
	' ".${table_name}.metadata")

	if [[ -z $valid_column_to_check ]]; then
		echo "Column not found"
		return 0
	fi

	
	if [[ $special_char_to_check = '=' ]]; then
		lines_to_change=$(awk -F'|' -v col="$valid_column_to_check" -v value="$data_to_check" '
			$col == value { print NR }
		' "$table_name")
	else 
		echo "enter = in the condtion"
	fi

	if [[ -z $lines_to_change ]]; then
		echo "No matching data found for the condition"
	else
		echo "Lines to change: $lines_to_change"
	fi


			if [[ ${#lines_to_change} -eq 0 ]]; then
				echo "There is no data with this value"
			else
				if [[ $is_pk -eq 1 ]]; then
					is_dublicat=$(awk -F"|" -v valid_column_to_check="$valid_column_to_check" -v value="$data_to_change" '
						$valid_column_to_check == value { print 1; exit }
						' "$table_name")

					if [[ $is_dublicat -eq 1 ]]; then
						echo "This pk already exists"
						return 0
					fi
					echo "You will change your pk value"
				else
					echo "Changing data is not pk"
				fi
				echo "Changing data here"
				echo $lines_to_change

				IFS=$'\n' read -rd '' -a lines_array <<< "$lines_to_change"

				for line in "${lines_array[@]}"
				do
					awk -F'|' -v col="$valid_column_to_change" -v new_val="$data_to_change" '{
						OFS="|";         
						$col = new_val;  
						print $0; 
					}' "$table_name" > temp_file && mv temp_file "$table_name"
				done
			fi
		fi


	elif [[ $# -eq 2  ]];
	then 
	echo "This will change all data in the column"


	condition_to_change=$2
	special_char=$(echo "$condition_to_change" | grep -o '[=]')

	if [[ $special_char =~ ^[=] ]]; then
		column_to_change=$(echo "$condition_to_change" | awk -F= '{print $1}')
		column_to_change=${column_to_change^^}  
		data_to_change=$(echo "$condition_to_change" | awk -F= '{print $2}')
	else
		echo "Enter a valid data format (column=value)"
		return 0
	fi
	valid_column=$(awk -F: -v column_to_change="$column_to_change" '
		$2 == column_to_change { print NR; exit }
	' ".${table_name}.metadata")

	is_pk=$(awk -F: -v column_to_change="$column_to_change" '
		$1 == "pk" && $2 == column_to_change {print 1; exit}
	' ".${table_name}.metadata")


	if [[ $valid_column ]]; then
		if [[ $is_pk -eq 1 ]]; then
			echo "You cannot make all the pk with the same value"
			return 0
		fi

		echo "Changing the data"

		valid_column_index=$(awk -F: -v column_to_change="$column_to_change" '
			$2 == column_to_change { print NR; exit }
		' ".${table_name}.metadata")

		echo "Column index: $valid_column_index"

		if [[ -z $valid_column_index ]]; then
			echo "Column not found in metadata"
			return 0
		fi

	
	awk -F'|' -v col="$valid_column_index" -v new_val="$data_to_change" '{
		$col = new_val; 
		OFS="|";        
		print $0;       
	}' "$table_name" > "$table_name" && mv temp_file "$table_name"


	else
		echo "The column $column_to_change was not found."
	fi

	fi

}

#function to delete the whole table including its structure
function drop_table() { 
    # check if no tables exists in the DB ---> echo "no tables to delete from the database" and return to main menu
	if [ -z "$(ls -A ./)" ]
	then 
		echo "There are no tables to delete from the database"	
		return
	fi

	# if there are tables in the DB --> prompt the user to enter the name of table to be deleted
	read -p "Please enter the name of the Table you want to delete : " table_name
    
	# Check if the table exists ---> remove the table file and the metadata file
    if [ -f "${table_name^^}" ]
    then
        # Use rm -f to avoid errors if the file doesn't exist
        rm -f "${table_name^^}"
		rm -f ".${table_name^^}.metadata"
        echo "Table '$table_name' has been deleted."
    else
        echo "Table '$table_name' does not exist."
    fi
}

#function to delete records from a table
function delete_from_table() {

	# Convert table name to uppercase to avoid case-senstive problems
	table_name=${1^^}
	echo $table_name

    if [[ ! -f $table_name ]]; then
        echo "This table does not exist."
        return 1
    fi

    # Check if the table is empty
    if [[ ! -s $table_name ]]; then
        echo "The table is empty."
        return 1
    fi

    # If 3 arguments are provided: table_name, WHERE clause, and condition
    if [[ $# -eq 3 ]]; then
        condition=$2
        check=$3
			
        # Extract column name and value from the condition
        check_name=$(echo "$check" | awk -F= '{print $1}')
		check_name=${check_name^^}
        check_data=$(echo "$check" | awk -F= '{print $2}')



        # Validate the WHERE clause
        if [[ $condition =~ [[:space:]]*[Ww][Hh][Ee][Rr][Ee][[:space:]]* ]]; then
            # Validate column name in metadata
            valid_column=$(awk -F: -v col_name="$check_name" '
                $2 == col_name { print NR; exit }
            ' ".${table_name}.metadata")

            if [[ -n $valid_column ]]; then
                # Find lines to remove based on the condition
                lines_to_remove=$(awk -F'|' -v col_num="$valid_column" -v value="$check_data" '
                    $col_num == value { print NR }
                ' "$table_name")

                if [[ -n $lines_to_remove ]]; then
                    # Delete matching lines
                    # Split the lines_to_remove into an array
                IFS=$'\n' read -rd '' -a lines_array <<< "$lines_to_remove"

                 for ((i=${#lines_array[@]}-1; i>=0; i--)); do
                      line="${lines_array[$i]}"
                      echo "Removing line $line"
                      sed -i "${line}d" "$table_name"
                done
                    echo "Records deleted successfully."
                else
                    echo "No matching records found."
                fi
            else
                echo "Column not found in metadata."
            fi
        else
            echo "Invalid condition. Please use a valid WHERE clause."
        fi

    # If 2 arguments are provided but no condition
    elif [[ $# -eq 2 ]]; then
        echo "You did not enter a valid condition."

    # If 1 argument is provided: table_name only
    elif [[ $# -eq 1 ]]; then
        echo "You provided only the table name. This will delete all data from the table."
        read -p "Do you want to delete all table data? (y/n): " answer
				if [ ${answer^^} = "Y" -o ${answer^^} = "YES" ]
				then 
					# delete all lines inside table file and keep the metadata file
					sed -i  'd' $table_name
					echo "All data has been deleted"
				elif [ ${answer^^} = "N" -o ${answer^^} = "NO" ]
				then
					#If the user entered "no" then abort deletion and return to the main menu 
					return 0
				else
					echo "invalid answers"
					return 0 
				fi

    else
        echo "Invalid number of arguments."
    fi
}

#function to select data from a table 
function select_from_table() {

	# if no tables exists in the DB ---> echo "no tables exists" and return to main menue
	if [ -z "$(ls -A ./)" ]
	then 
		echo "There are no tables to select from in the database"	
		return
	fi

	# prompt the user to enter the name of the table
	read -p "Please enter the name of the Table you want to select from: " table_name

	# Convert table name to uppercase
	table_name=${table_name^^}

    # Check if the table exists
    if [[ ! -f $table_name ]]
	then
        echo "This table does not exist."
        return 1
    fi

    # Check if the table is empty
    if [ ! -s $table_name ]
	then
        echo "The table is empty."
        return 1
    fi

	echo "Please choose an option to select data from table($table_name): "
	select option in "Display all table data" "Display specific rows according to condition" "Display specific columns"
	do
		case $option in 
			"Display all table data") # select * from students
				awk -F'|' '{print $0}' "./$table_name"
				return
			;;

			"Display specific rows according to condition") # select * from students where name=ahmed
				read -p "Enter specific column to apply condition on: " columns
				# we search using awk for the column name entered by the user, which is stored in the second field of the cloumn meta data [ pk:COL_name:COL_datatype ]
				# then we store the value of column name in (col_name) variable and print the row number of meta data {which is the column number in the data table}
				valid_column=$(awk -F: -v col_name="${columns^^}" '
					$2 == col_name { print NR; exit }
				' ".${table_name}.metadata")

				# get type of column from the metadata file
				valid_datatype=$(awk -F: -v col_name="${columns^^}" '
					$2 == col_name { print $3; exit }
				' ".${table_name}.metadata")

				# prompt the user for the value of data being compared (str/ int)
				# if the datatype is string 
				if [ $valid_datatype = "str" ]
				then
					# prompt the user to enter the operator
					read -p "Enter condition operator: equal(=) or not-equal(!=): " operator

					#prompt the user for the value being compared
					read -p "Enter value of condition: " check_data

					if [ $operator = "=" ]
					then
						awk -F'|' -v valid_column="$valid_column" -v value="$check_data" '
						$valid_column == value { print $0 }
						' "$table_name"

					elif [ $operator = "!=" ]
					then 
						awk -F'|' -v valid_column="$valid_column" -v value="$check_data" '
						$valid_column != value { print $0 }
						' "$table_name"
					else 
						echo "Invalid input. Please try again."
					fi

					# if the column datatype is intger
					elif [ $valid_datatype = "int" ]
					then 
						# prompt the user to enter the operator
						read -p "Enter operator:( = / > / < / >= / <= / not equal(!=): " operator
						#prompt the user for the INTEGER value being compared
						declare -i check_data
						read -p "Enter value of condition: " check_data
						# switch case to perform the selection based on operator entered by user
						case $operator in
						"=")
							awk -F'|' -v valid_column="$valid_column" -v value="$check_data" '
							$valid_column == value { print $0 }
							' "$table_name"
							;;
						
						">")
							awk -F'|' -v valid_column="$valid_column" -v value="$check_data" '
							$valid_column > value { print $0 }
							' "$table_name"
							;;
						
						"<")
							awk -F'|' -v valid_column="$valid_column" -v value="$check_data" '
							$valid_column < value { print $0 }
							' "$table_name"
							;;
						
						">=")
							awk -F'|' -v valid_column="$valid_column" -v value="$check_data" '
							$valid_column >= value { print $0 }
							' "$table_name"
							;;
						
						"<=")
							awk -F'|' -v valid_column="$valid_column" -v value="$check_data" '
							$valid_column <= value { print $0 }
							' "$table_name"
							;;
						
						"!=")
							awk -F'|' -v valid_column="$valid_column" -v value="$check_data" '
							$valid_column != value { print $0 }
							' "$table_name"
							;;	
						*)
							echo "Invalid input. Please try again."
							;;
						esac
					fi
			;;
			*)
				 echo "Invalid input. Please try again."
			;;
		esac
	done
}

echo "Please choose an option: "
# Menu to chosse a command from
select option in "Create Table" "Rename Table" "List all Tables" "Delete Table" "Insert Into Table" "Select from Table" "Delete from Table" "Update Table" "Exit"; do
    case $option in
        "Create Table")
            create_table
            ;;
            
        "List all Tables")
            list_tables
            ;;
            
        "Delete Table")    
            drop_table
            ;;
            
        "Insert Into Table")
            insert_into
            ;;
            
        "Select from Table")
            select_from_table
            ;;
        
        "Delete from Table")
			echo "Example: 1. table_name where condition -> to delete a specific row"
			echo "Example: 2. table_name  -> to delete all table "

			read -p "Please enter the name of the Table  you want to delete from: " table_name
           	 delete_from_table $table_name
            ;;
            
        "Update Table")
		echo "example 1 : table_name data_to_change=value where condition -> updata spasifc row "
		echo "example 2 : table_name data_to_change=value  -> updata all the column with this value "

            read -p "Please enter the name of the Table you want to update: " table_name
            update_table $table_name  
            ;;
    
        "Rename Table")
            rename_table
            ;;
    
        "Exit")
            read -p "Do you want to exit? (yes/no): " confirm_exit
            case ${confirm_exit^^} in
                Y|YES)
                    echo "You exited the database."
                    # Return to the DMBS directory and restart main.sh
                    cd ..
                    . ./main.sh
                    break
                    ;;
                N|NO)
                    echo "You are still in the database. Choose an option."
                    ;;
                *)
                    echo "Invalid input. Please respond with yes or no."
                    ;;
            esac
            ;;
        
        *)
            echo "Invalid input. Please try again."
            ;;
    esac
	done