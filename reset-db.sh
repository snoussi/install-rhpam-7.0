#!/bin/bash

echo "SET DB USERNAME"
echo "SET DATABASE_NAME"

USERNAME=changeme

DATABASE_NAME=pam_db

echo "Resetting PSQL DB"

psql -U $USERNAME -c "DROP DATABASE $DATABASE_NAME"
psql -U $USERNAME -c "CREATE DATABASE $DATABASE_NAME"