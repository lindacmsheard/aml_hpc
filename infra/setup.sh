#!/bin/bash

# load environment variables from a .env file
source .env

R=$((RANDOM%1000))
RG="${RG}_${R}"

WS="${RG}_ws"

# set local setup variables
VM_SIZE=Standard_DS2_v2
VM_IMAGE=Ubuntu2204
VM_NAME="vm_${R}"
VM_USER=azureuser
VM_PASSWORD="HPCjumpbox@${R}"

echo "VM_PASSWORD=${VM_PASSWORD}" >> .env


echo "Working in subscription:"
echo "-- $(az account show -o tsv --query name) --"
echo "Continue? (y/N)"  
read  

if [ $REPLY = 'y' ]; then

    # RG
    echo "Creating resource group $RG..."

    az group create -n $RG --location $LOCATION
    echo "$RG created."

    # AML Workspace
    echo "Creating Azure Machine Learning workspace and associated resources..."
    az ml workspace create -n $WS -g $RG --location $LOCATION
    echo "$WS created."

    # VM
    echo "Creating VM..."
    VM_ID=$(az vm create -n $VM_NAME -g $RG --image $VM_IMAGE --size $VM_SIZE --admin-username $VM_USER --admin-password $VM_PASSWORD --public-ip-sku Standard --query id -o tsv)
    echo "$VM_ID created."
    echo "VM_ID=${VM_ID}" >> .env


    # set defaults
    echo "Setting defaults..."
    az configure --scope local -d group=$RG location=$LOCATION workspace=$WS
    az configure --scope local --list-defaults

else
    echo -e "Please log in with \n\n  az login --tenant yourtenant \n\nand set the correct subscription with \n\n  az account set -s <subscription>.\n"
    echo "Ensure the ml extension for the azure cli is installed." 
fi
