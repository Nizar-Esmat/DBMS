#! /usr/bin/bash


function validate_name(){

	#To implement --->
}


#function to create a table(file) in the database(directory)
function create_table(){
	#check if the file already exists 
	if [ -f $1 ]
	then 
		echo "Table ($1) already exists"
	else 
		#if the no table with the entered name exists then check the constrains on the name 
		if [ validate_name $1 ]
		then 
			# if the entered name is valid ---> make a file meta_data to store the columns names and its constrains
			# prompt the user for the number of columns
			read -p "Enter the number of columns" column_numbers
			for ((i=0;i<$column_numbers;i++))
			do
				read -p "Enter column name: " column_name
				
			
			done
		else
			echo "You entered an invalid name \n Table name should not contain ######"
		
		
			
	#TO IMPLEMENT ---> Tarek



}

#function to rename an existing table in the DB
function rename_table() {
	#TO IMPLEMENT ---> Tarek



}

#function to list table names in a database
function list_tables(){
	
	#TO IMPLEMENT --->  Nizar
	
	
	
}

#function to add records to a table
function insert_into(){
	
	#TO IMPLEMENT ---> Nizar



}

#function to present some records from a table
function select_from_table(){
	
	#TO IMPLEMENT ---> Tarek


}

#function to update records in a table
function update_table(){
	
	#TO IMPLEMENT ---> Tarek


}

#function to delete the whole table including its structure
function drop_table(){
	
	#TO IMPLEMENT --->  Nizar
	
	
}

#function to delete the table data but keep the structure
function truncate_table(){
	
	#TO IMPLEMENT --->  Tarek
	
	
}

#function to delete records from a table
function delete_from_table(){
	
	#TO IMPLEMENT ---> Nizar


}



select option in "Create Table"  "List all Tables" "Delete Table" "Insert Into Table" "Select from Table " "Delete from Table" "Update Table" "Exit"
do
	case $option in 
		"Create Table")
			read -p "Please enter the name of the Table you want to create: " table_name
			create_table $table_name
			;;
			
		"List all Tables")
			list_tables
			;;
			
		"Delete Table")
			read -p "Please enter the name of the Table you want to delete: " table_name
			# prompt the user to decide if he/she wants to keep the structure of table or not
			if []
			then
				drop_table $table_name
			else
				truncate_table $table_name
			fi
			
			;;
			
		"Insert Into Table")
			read -p "Please enter the name of the Table you want to insert into: " table_name
			insert_into $table_name
			;;
			
		"Select from Table ")
			read -p "Please enter the name of the Table you want to select from: " table_name
			select_from_table $table_name
			;;
		
		"Delete from Table")
			read -p "Please enter the name of the Table you want to delete from: " table_name
			delete_from_table $table_name
			;;
			
		"Update Table")
			read -p "Please enter the name of the Table you want to update: " table_name
			update_table $table_name
			;;
		
		"Exit")
			do
				read -p "Do you want to exit? (yes/no): " exit
				if [[  $exit =~ "yes" ]]
				then
					echo "You exited the database"
					# if the user choose to exit then return to the DMBS directory
					cd ..
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




