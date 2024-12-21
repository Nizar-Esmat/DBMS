#! /usr/bin/bash

# Functions that validates the name of a table
# Returns 1 if the name is valid, return 0 if the name is invalid
function validate_name(){
	# To implement ---> Tarek
	return 1
	
	# NizAr ---> true 
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
	
	#TO IMPLEMENT ---> Nizar



}

#function to present some records from a table
# function select_from_table(){
	
# 	#TO IMPLEMENT ---> Tarek


# }

#function to update records in a table
# function update_table(){
	
# 	#TO IMPLEMENT ---> Tarek


# }







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
			
		# "Insert Into Table")
		# 	read -p "Please enter the name of the Table you want to insert into: " table_name
		# 	insert_into $table_name
		# 	;;
			
		# "Select from Table ")
		# 	read -p "Please enter the name of the Table you want to select from: " table_name
		# 	select_from_table $table_name
		# 	;;
		
		# "Delete from Table")
		# 	delete_from_table $table_name
		# 	;;
			
		"Update Table")
			read -p "Please enter the name of the Table you want to update: " table_name
			update_table $table_name
			;;
		
		"Exit")
			while true
			do
				read -p "Do you want to exit? (yes/no): " exit
				if [[  $exit =~ "yes" ]]
				then
					echo "You exited the database"
					# if the user choose to exit then return to the DMBS directory and run the main.sh scipt to start from the begining
					cd ..
					. ./main.sh
					break
					
				elif [[ $exit =~ "no" ]]
				then
					echo "You are still in the database. Choose an option."
					break
				else
					echo "Invalid input."
				fi
			done
		;;
			
		*)
			echo "Invalid input. Please try again."
	esac
done   
