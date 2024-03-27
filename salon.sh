#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?\n"
  PROVIDED_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$PROVIDED_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That is not a valid service"
  else
    SERVICE_EXISTS=$($PSQL "SELECT service_id from services where service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_SELECTED ]]
    then
      MAIN_MENU "That service doesn't exist"
    else
      echo -e "\nWhat's your phone number?" 
      read CUSTOMER_PHONE
      CUSTOMER_EXISTS=$($PSQL "SELECT customer_id from customers where phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_EXISTS ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        CREATE_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone = '$CUSTOMER_PHONE'")
      echo -e "\nWhat time would you like your service, $CUSTOMER_NAME"
      read SERVICE_TIME
      CREATE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      SERVICE_NAME=$($PSQL "SELECT name FROM services where service_id = $SERVICE_ID_SELECTED")
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU
