#!/bin/bash 
#function to create data base
clear
function createDB(){
    read -p "Enter the name of the database: " dbName


    validateName $dbName
    validation_result=$?
    if (($validation_result)); then 
        if [[ ! -d "$dbName" ]]; then 
            mkdir $dbName
            echo "Database created."
        else 
            echo "This database already exists."
        fi
    else
        echo "You have an error."
    fi
}		
#function to validate the input 
function validateName() {
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

listDB() {
    # Loop over the directory names (Databases) to remove the last character (/)
    count=0
    for dir in `ls -d */`
    do
        echo "${dir%/}"
        count=$(($count + 1))
    done
    echo "The number of databases is $count."
}

echo "Enter the option you want"

select option in "Create Database" "List Databases" "Delete Database" "Connect to Database" "Exit"
do
    case $option in
        "Create Database")
            echo "You selected Create Database."
            createDB
            ;;
        "List Databases")
            echo "You selected List Databases."
            listDB
            ;;
        "Delete Database")
            echo "You selected Delete Database."
            ;;
        "Connect to Database")
            echo "You selected Connect to Database."
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

