#!/bin/bash

# Check if argument is provided
if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Set the input to a variable
element=$1

# Check if the input is numeric (atomic number)
if [[ "$element" =~ ^[0-9]+$ ]]; then
  # If it's a number, use it as atomic_number
  result=$(psql -U postgres -d periodic_table -t -c "
    SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
    FROM elements e
    JOIN properties p ON e.atomic_number = p.atomic_number
    JOIN types t ON p.type_id = t.type_id
    WHERE e.atomic_number = '$element';
  ")
else
  # If it's not a number, check for symbol or name
  result=$(psql -U postgres -d periodic_table -t -c "
    SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
    FROM elements e
    JOIN properties p ON e.atomic_number = p.atomic_number
    JOIN types t ON p.type_id = t.type_id
    WHERE e.symbol = '$element' OR e.name = '$element';
  ")
fi

# Format the result and output
if [ -z "$result" ]; then
  echo "I could not find that element in the database."
else
  # Extract fields from result
  atomic_number=$(echo "$result" | awk -F '|' '{print $1}' | xargs)
  name=$(echo "$result" | awk -F '|' '{print $2}' | xargs)
  symbol=$(echo "$result" | awk -F '|' '{print $3}' | xargs)
  atomic_mass=$(echo "$result" | awk -F '|' '{print $4}' | xargs)
  melting_point=$(echo "$result" | awk -F '|' '{print $5}' | xargs)
  boiling_point=$(echo "$result" | awk -F '|' '{print $6}' | xargs)
  type=$(echo "$result" | awk -F '|' '{print $7}' | xargs)

  # Output in desired format
  echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
fi