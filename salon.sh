#!/bin/bash
# Script to create a salon appointment

echo -e "\n~~~~~ MY SALON ~~~~~\n"
PSQL="psql --username=freecodecamp --dbname=salon -t -A -c"

# display services
echo -e "Welcome to My Salon, how can I help you?\n"

SERVICES=$($PSQL "SELECT name FROM services")

I=1
for SERVICE in $SERVICES
do    
    echo -e "$I) $SERVICE"
    ((I=I+1))
done

read SERVICE_NUMBER

J=1
for SERVICE in $SERVICES
do
    if [[ $J -eq $SERVICE_NUMBER ]]
    then
        SERVICE_NAME=$SERVICE
    fi
    ((J=J+1))
done

SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE name = '$SERVICE_NAME'")

# until valid service number is entered
while [[ -z $SERVICE_ID_SELECTED ]]
do
    echo -e "\nI could not find that service. What would you like today?"
    J=1
    for SERVICE in $SERVICES
    do
        echo -e "$J) $SERVICE"
        ((J=J+1))
    done

    read SERVICE_ID_SELECTED

    J=1
    for SERVICE in $SERVICES
    do
        if [[ $J -eq $SERVICE_ID_SELECTED ]]
        then
            SERVICE_NAME=$SERVICE
        fi
        ((J=J+1))
    done

    SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE name = '$SERVICE_NAME'")
done



# get service id

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_ID ]]
then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
    then
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi
else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (service_id, customer_id, time) VALUES ($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi

