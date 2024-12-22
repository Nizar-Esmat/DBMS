#! /bin/usr/bash
function validate_name(){

# if the user entered an unallowed charcter: ! @ # $ % ^ & * [ ] ( ) .
	if [[ $1 =~ [^A-Za-z0-9_] ]]; then
        echo "Invalid name: Cannot contain special characters."
        return 0
    fi
}

