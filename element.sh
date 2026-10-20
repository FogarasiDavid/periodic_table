#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

if ! ELEMENT=$(
  psql --username=freecodecamp --dbname=periodic_table --tuples-only --no-align \
    --set=element="$1" <<'SQL'
SELECT atomic_number, name, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius, symbol
FROM elements
JOIN properties USING (atomic_number)
JOIN types USING (type_id)
WHERE name = :'element'
  OR symbol = :'element'
  OR atomic_number::text = :'element';
SQL
); then
  exit 1
fi

if [[ -z "$ELEMENT" ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r atomic_number name type atomic_mass melting_point boiling_point symbol <<< "$ELEMENT"
echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
