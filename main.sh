#!/bin/bash 

# Create a select to choose the option 
echo "Enter the option you want"

select option in "Create Database" "List Databases" "Delete Database" "Connect to Database" "exit"
do
    case $option in
        "Create Database")
            echo "You selected Create Database"
            ;;
        "List Databases")
            echo "You selected List Databases"
            ;;
        "Delete Database")
            echo "You selected Delete Database"
            ;;
        "Connect to Database")
            echo "You selected Connect to Database"
            ;;
        "exit")
            read -p "Do you want to exit? (yes/no): " exit
            if [[  $exit =~ "yes" ]]; then
                echo "You exited the system"
                break
            elif [[ $exit =~ "no" ]]; then
                echo "You are still in the system, choose an option"
                continue
            else
                echo "Invalid input"
            fi
            ;;
        *)
            echo "Invalid input. Please try again."
            ;;
    esac
done

