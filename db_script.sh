#! /usr/bin/bash

# Functions that validates the name of a table
# Returns 1 if the name is valid, return 0 if the name is invalid
function validate_table_name() {
  
  local table_name=$1
	
	# if the user entered a name that exceedes the maximum allowed characters
  if [ ${#table_name} -gt 64 ]
  then 
    echo 'Invalid table name. Table name exceed maximum allowed length.'
    echo 'Please enter a name less than 64 charcters.'
    return 0
  fi

	# if the user entered an empty string 
  if [ -z $table_name ]
	then
    echo "Invalid table name. Table name must be at least one character."
    return 0
  fi

	# if the user entered a space in the name
	if [[ $table_name =~ [[:space:]] ]]
	then
  		echo "Invalid table name. Table name can not contain spaces."
      return 0
	fi

	# if the user entered a name which starts with a number 
	if [ $table_name =~ ^[0-9] ]
  then
        echo "Invalid table name. Table name cannot start with a number."
        return 0
  fi
	
	# if the user entered an unallowed charcter: ! @ # $ % ^ & * [ ] ( ) .
	if [ $table_name =~ [^A-Za-z0-9_] ]
  then
        echo "Invalid table name. Table name cannot contain special characters."
        return 0
  fi

	# if the user entered a name which starts with underscore _
	if [ $table_name = ^_ ]
	then
  		echo "Invalid table name. Table name Cannot start with an underscore."
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
      if [ "$keyword" == "$table_name^^" ]
      then
          found_flag=1
          break
      fi
  done

  # Check the flag if it equal to 1 ---> print error 
  if [ $found_flag -eq 1 ]
  then
      echo "Invalid table name.Table name cannot be an SQL keyword."
      return 0
  fi

return 1 

}


#function to create a table(file) in the database(directory)
function create_table(){
	# Prompt the user to enter the name of the table
	read -p "Please enter the name of the table you want to create: " table_name

	# Check if the file already exists
	if [ -f ${table_name^^} ]
	then 
		echo "Table ($table_name) already exists"
	# if the table does't exist ---> validate the table name 
	else 
		# case(1): if the name entered is valid 
		if [ validate_name $table_name ]
		then 
			# if the entered name is valid ---> make a file to store the table's data
			touch ${table_name^^}
	
			# Make a (hidden) file meta_data to store the columns names and its constrains
			touch .${table_name^^}.metadata
			
			# prompt the user for the number of columns
			read -p "Enter the number of columns" column_numbers
			
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
				if [ validate_name $column_name ]
				then
					column_data = $column_data + ":" + ${column_name^^}
				# If the user entered an invalid name ---> keep re-prompting for a valid name
				else 
					while true 
					do 
						# Reprompt the user to enter column_name
						read -p "Enter column($(($i + 1))) name: " column_name
						# If the user entered a valid name ---> break from the loop
						if [ validate_name $column_name ]
						then
							column_data = $column_data + ":" + ${column_name^^}
							break
						fi
					done
				fi
				
				# Prompt the user to enter the column datatype
				read -p "Enter column($(($i + 1))) datatype (int/str)" col_datatype
				# Check if the user entered a valid data_type
				if [ ${col_datatype^^} == "INT" -o $col_datatype == "INTGER"]
				then 
					column_data+=":int"
				
				elif [ ${col_datatype^^} == "STR" -o $col_datatype == "STRING"]
					column_data+=":str"

				# If the user entered an invalid datatype ---> keep re-prompting for a valid datatype
				else 
					while true 
					do
						echo 'You entered an invalid datatype. Allowed datatypes are strings & intgers'
						read -p "Please enter (str) to store strings and (int) to store intgers" col_datatype
						# if the user entered a valid datatype break from the loop
						if [ ${col_datatype^^} = "INT" -o ${col_datatype^^} = "INTEGER"]
						then 
							column_data+=":int"
							break
						elif [ ${col_datatype^^} = "STR" -o ${col_datatype^^} = "STRING" ]
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
						if [ ${PK^^} = "Y" -o $PK = "YES" ]
						then 
							# Change (pk_flag) status to be 1 ---> so no other column set to be PK
							$pk_flag=1
							column_data = "pk" + $column_data  # the final form of the meta_data about column ---> PK:COLUMN_NAME:column_data_type
							break
						
						# if the user entered no / n
						elif [ ${PK^^} = "N" -o $PK = "NO" ]
						then
							column_data = "npk" + $column_data # the final form of the meta_data about column ---> npk:COLUMN_NAME:column_data_type
							break

						# if the user entered an invalid option
						else
							echo "Invalid option." 
							read "Enter (y) to set column($column_name) to be a Primay Key, Enter(n) otherwise" PK
						fi
					done 

				# ---> if there is a choosen Primary key
				else 
					column_data = "npk" + $column_data   # the final form of the meta_data about column ---> npk:COLUMN_NAME:column_data_type
				fi

				# Append the column metadata to the table_meta_data file
				echo $column_data >> .$table_name.metadata
			done
		else
			echo "You entered an invalid name"	
		fi	
	fi
}



#function to rename an existing table in the DB
function rename_table() {
	#Prompt the user to enter the current name of table
	read -p "Please enter the name of table you want to rename:" table_name
	if [ -f ${table_name^^} ]
	then	
		while true
		do
			read -p "Please enter the new name: " table_new_name 
			if [ validate_name $table_new_name  ]
			then 
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
	
    for file in `ls -h | grep -v '^d'`
    do
        echo $file
    done
}


#function to add records to a table
function insert_into(){
	local table_name=${1^^}
	echo $table_name

	if [ -f $table_name ]; then
		if [[ $# > 1 ]];
		then 
		echo "you must enter the tabel name only";
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
						done < ./${table_name}.metadata


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

  			  if [[ $is_pk -eq 1 ]]; then
    	  	    if [[ ${freq_array[$dt]} -ge 1 ]]; then
    		        echo "The primary key cannot be duplicate."
    		        return 0
     		   else
       			     freq_array["$dt"]=$(( ${freq_array["$dt"]} + 1 ))
      			  fi
  			  fi

  				if [[ ${type[$i]} =~ "int" && ! $dt =~ ^[0-9]+$ ]]; then
   				     echo "Error: Not a number."
   				     return 0
    			elif [[ ${type[$i]} =~ "str" && ! $dt =~ ^[A-Za-z_]+$ ]]; then
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


#function to update records in a table
# function update_table(){
	
# 	#TO IMPLEMENT ---> Tarek


# }





#function to delete the whole table including its structure
function drop_table() {
    local table_name=${1^^}

    # Check if the file (table) exists
    if [ -f "$table_name" ]
    then
        # Use rm -f to avoid errors if the file doesn't exist
        rm -f ./"$table_name"
		    rm -f ./"$table_name.metadata"
        echo "Table '$table_name' has been deleted."
    else
        echo "Table '$table_name' does not exist."
    fi
}


#function to delete records from a table
function delete_from_table(){
	# table_name where condtion
	table_name=${1^^}

	if [ -f $table_name ];then
	if [ -s $table_name ];then
	 
		if [[ $# -eq 3 ]]; #name where id=5
			then
				condtion=$2
				check=$3
				check_name=$(echo "$check" | awk -F= '{print $1}')
				check_data=$(echo "$check" | awk -F= '{print $2}')
				if [[ $condtion =~ [[:space:]]*[Ww][Hh][Ee][Rr][Ee][[:space:]]* ]]; then
						valid_culmn=$(awk -F: -v  check_name="$check_name"  '
						 awk{
						 
						 	if (check_name == $2)
							{
								print NR
								exit;
							}
						 }

						 ' ./${table_name}.metadata)

					if [[ -n $valid_culmn ]];
					then
							lines_to_remove=$(awk -F'|' -v valid_culmn="$valid_culmn" -v check_data="$check_data" '
								  BEGIN {
								   lines=""
								    }
									{
									 if ($valid_culmn == check_data) {
									 stNR= NR ""
										 lines=lines""stNR
										}

									}
									END {
										print lines
										}
											' ./${table_name})

								for (( line=${#lines_to_remove}; line>0; line-- )); do
   									 echo "Removing line $line"
  							  		sed -i "${line}d" ./data
								done


					else
						echo "Column not found"
					fi

					else
    					echo "Enter a correct condition"
				fi

		elif [[ $# -eq 2  ]]; 
			then 
				echo "you did not enter the condtion"
		elif [[ $# -eq 1  ]];
			then
				echo "you enter one arguments will remoev all data from the table"
				# prompt the user to decide if he/she wants to delete all table data or a specific record/s
				read -p "Do you want to delete all table data? (y/n): " answer
				if [ ${answer^^} = "Y" -o ${answer^^} = "YES" ]
				then 
					# delete all lines inside table file and keep the metadata file
					sed -i  'd' $table_name
				elif [ ${answer^^} = "N" -o ${answer^^} = "NO" ]
				then
					#If the user entered "no" then abort deletion and return to the main menu 
					return 0
				else
					echo "invalid answers"
					return 0 
				fi

		else
			echo "your file is empty"
		fi
	else
		echo "this table dose not exist"
	fi

# Menu to chosse a command from
select option in "Create Table"  "List all Tables" "Delete Table" "Insert Into Table" "Select from Table " "Delete from Table" "Update Table" "Exit"
do
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
			read -p "Please enter the name of the Table you want to insert into: " table_name
			insert_into $table_name
			;;
			
		# "Select from Table ")
		# 	read -p "Please enter the name of the Table you want to select from: " table_name
		# 	select_from_table $table_name
		# 	;;
		
		"Delete from Table")
			delete_from_table $table_name
			;;
			
# 		"Update Table")
# 			read -p "Please enter the name of the Table you want to update: " table_name
# 			update_table $table_name
# 			;;
		
		"Exit")
			while true
			do
				read -p "Do you want to exit? (yes/no): " confirm_exit
				if [  ${confirm_exit^^} = "Y" -o ${confirm_exit^^} = "YES" ]
				then
					echo "You exited the database"
					# if the user choose to exit then return to the DMBS directory and run the main.sh scipt to start from the begining
					cd ..
					. ./main.sh
					break
		
				elif [ ${confirm_exit^^} = "N" -o ${confirm_exit^^} = "NO" ]
				then
					echo "You are still in the database. Choose an option."
				else
					echo "Invalid input."
				fi
			done
		  ;;
	
		*)
			echo "Invalid input. Please try again."
	esac
done  
