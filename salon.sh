#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name from services ORDER BY service_id")
  echo -e "\nWhat service would you like to book?"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That service does not exist. Please select a valid service"
  else
    SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_SELECTED ]]
    then
      MAIN_MENU "That service does not exist. Please select a valid service"
    else
      echo -e "\nPlease provide a phone number"
      read CUSTOMER_PHONE

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo "$CUSTOMER_ID"
      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "\nCustomer not registered. Please enter a name:"
        read CUSTOMER_NAME
        CUSTOMER_INSERT=$($PSQL "INSERT INTO customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        echo "Customer inserted succesfully"
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      fi
      echo -e "\nPlease enter the time you would like to book:"
      read SERVICE_TIME

      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo "$INSERT_APPOINTMENT_RESULT"
      echo -e "\nI have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU