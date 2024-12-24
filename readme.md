# DBMS Project with Bash

## Overview

This project is a **Database Management System (DBMS)** implemented entirely using **Bash scripting**. It was developed as part of the **Bash course** during my training at the **Information Technology Institute (ITI)**. The system provides basic functionality for managing databases and tables through a command-line interface.

## Features

- **Database Management**:

  - Create and navigate databases.
  - List all available databases.
  - Delete databases.

- **Table Management**:

  - Create tables with column definitions.
  - Rename tables.
  - List all tables in a database.
  - Delete tables.

- **Data Manipulation**:

  - Insert data into tables.
  - Select data with filtering options.
  - Update existing data in tables.
  - Delete data from tables.

## Project Structure

- **main.sh**: The entry point script that initializes the DBMS and handles database selection.
- **db\_script.sh**: Contains the core logic for database operations such as creating, navigating, and deleting databases.
- **metadata files**: Used to store schema information for each table.
- **data files**: Contain the actual data for each table.

## How to Run the Project

1. Clone or download the project repository.
2. Open a terminal and navigate to the project directory.
3. Run the following command to start the DBMS:
   ```bash
   ./main.sh
   ```
4. Follow the interactive prompts to perform database and table operations.

## Usage Example

### 1. Creating a Database

- Choose the option to create a database and enter the desired name.

### 2. Creating a Table

- Define the table name and column structure.

### 3. Inserting Data

- Enter values for each column in the table.

### 4. Querying Data

- Use filtering conditions to retrieve specific rows from the table.

### 5. Updating or Deleting Data

- Specify the condition to match rows and update or delete as needed.

## Key Concepts

- **Metadata Files**: These files store schema definitions for each table, including column names and primary key information.
- **Data Storage**: Data is stored in plain text files, with each row separated by a newline and columns separated by a delimiter (`|`).
- **Validation**: The system ensures that data conforms to the schema and handles errors such as duplicate primary keys or invalid column names.

## Skills Demonstrated

- Shell scripting and Bash programming.
- String manipulation and text processing using tools like `awk`, `sed`, and `grep`.
- File handling and input validation.
- Implementation of basic database functionalities.

## Acknowledgments

This project was completed as part of my coursework at the **Information Technology Institute (ITI)** during the **Bash course**. Special thanks to my instructors and peers for their guidance and support.


