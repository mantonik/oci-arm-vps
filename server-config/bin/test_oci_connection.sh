#!/bin/bash 
oci setup repair-file-permissions --file /root/.oci/config 
oci iam region list --output table
