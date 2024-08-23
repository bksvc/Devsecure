#!/bin/bash

#######################################
# This Script Created By: Burak Savcı #
#######################################

###############################################################################################
#																							  #
# WARNING !!! 																				  #
#																							  #
# Responsibility for any unauthorized use or misuse of this resource rests entirely with you. #
#																							  #
###############################################################################################

# IF THERE IS AN ERROR, STOP
set -euo pipefail

setVariables(){
    # SET DB VARIABLES
    sqluname="${DB_USER:-username}"
    sqlpass="${DB_PASS:-password}"
    sqldbname="${DB_NAME:-dbname}"
    sqltable="${DB_TABLE:-tablename}"
    sqlcolumn="${DB_COLUMN:-columnname}"

    # SET TIME AND LINK VARIABLES
    taketime=$(date "+%d-%m-%Y--%H-%M-%S")
    link="https://www.usom.gov.tr/url-list.txt"
}

# After create directory grab data
createDirectoryAndTakeData(){
    mkdir "$taketime" && cd "$taketime" && wget "$link" -O "$taketime-usom.txt"
}

# Compare new data with existing data in the database and add missing data to the database
beginToWork(){

    mysql -u "$sqluname" -p"$sqlpass" -D "$sqldbname" -e "SELECT $sqlcolumn FROM $sqltable" > "$taketime-db-out.txt"

    cat "$taketime-db-out.txt" "$taketime-usom.txt" | sort | uniq -u > "$taketime-insert-out.txt"

    while read -r stack;
    do
        mysql -u "$sqluname" -p"$sqlpass" -D "$sqldbname" -e "INSERT INTO $sqltable($sqlcolumn) VALUES ('$stack');"

        echo "Added : $stack" >> $taketime-addedlist.txt

    done < $taketime-insert-out.txt
}
# LOAD .env FILE
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    # Main Execution #
    setVariables
    createDirectoryAndTakeData
    beginToWork
else
    echo "Please set database information"
    exit 1
fi
