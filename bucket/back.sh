#!/bin/bash

secret=`terraform output -raw terraform_backend_secret_key`
access=`terraform output -raw terraform_backend_access_key`
#echo $secret
#echo $access
echo terraform init -backend-config='"'access_key=$access'"' -backend-config='"'secret_key=$secret'"'
