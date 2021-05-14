#!/bin/bash

export ARM_CLIENT_ID=""

export ARM_CLIENT_SECRET=""

export ARM_TENANT_ID=""

export subscription_id=""
export TF_VAR_subscription_id=$subscription_id

export resource_group_name="rg-terraform-backend-eastus"
export TF_VAR_resource_group_name=$resource_group_name

export storage_account_name=""
export TF_VAR_storage_account_name=$storage_account_name

export key="linklist-terraform.tfstate"
export TF_VAR_key=$key

export container_name="tstate"
export TF_VAR_container_name=$container_name

export TF_VAR_app_client_secret=""

export TF_VAR_custom_domain=""

export TF_VAR_cert_kv_name=""