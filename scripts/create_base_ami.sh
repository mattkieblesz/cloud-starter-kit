#!/bin/bash

readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly BASE_DIR=$( cd $SCRIPT_DIR/.. && pwd )
readonly STORE_BUCKET_NAME=$( cd $BASE_DIR && basename $(pwd) )
readonly IMAGE_NAME="trusty-server-cloudimg-amd64.ova"
readonly FORMAT="ova"
readonly DESCRIPTION='Ubuntu 14.04.5 LTS'

source "$SCRIPT_DIR/utils.sh"

main() {
    # inf "--> Download base image"
    # wget https://cloud-images.ubuntu.com/trusty/current/$IMAGE_NAME -o /tmp/$IMAGE_NAME

    # inf "--> Upload base image to s3"
    # /usr/local/bin/aws s3 cp /tmp/$IMAGE_NAME s3://$STORE_BUCKET_NAME/vms/$IMAGE_NAME
    # rm /tmp/$IMAGE_NAME

    if [ $(/usr/local/bin/aws iam list-roles | grep 'vmimport' | wc -l) -eq "0" ] ; then
        inf "--> Create AWS role which will have access to s3 and ec2"
        cat > /tmp/trust-policy.json <<EOL
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": { "Service": "vmie.amazonaws.com" },
         "Action": "sts:AssumeRole",
         "Condition": {
            "StringEquals":{
               "sts:Externalid": "vmimport"
            }
         }
      }
   ]
}
EOL
        /usr/local/bin/aws iam create-role --role-name vmimport --assume-role-policy-document file:///tmp/trust-policy.json
        rm /tmp/trust-policy.json

        inf "--> Create and attach policy"
        cat > /tmp/role-policy.json <<EOL
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation"
         ],
         "Resource": [
            "arn:aws:s3:::$STORE_BUCKET_NAME"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "s3:GetObject"
         ],
         "Resource": [
            "arn:aws:s3:::$STORE_BUCKET_NAME/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action":[
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
         ],
         "Resource": "*"
      }
   ]
}
EOL
        /usr/local/bin/aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document file:///tmp/role-policy.json
        rm /tmp/role-policy.json
    fi

    inf "--> Import uploaded image as AMI"
    cat > /tmp/containers.json <<EOL
[
    {
        "Description": "$DESCRIPTION",
        "Format": "$FORMAT",
        "UserBucket": {
            "S3Bucket": "$STORE_BUCKET_NAME",
            "S3Key": "vms/$IMAGE_NAME"
        }
    }
]
EOL
    /usr/local/bin/aws ec2 import-image --description=$DESCRIPTION --license-type BYOL --disk-containers file:///tmp/containers.json --platform Linux
    rm /tmp/containers.json

    /usr/local/bin/aws ec2 describe-import-image-tasks
    warn "--> Now wait until import process will be finished"
    # /usr/local/bin/aws ec2 describe-import-image-tasks
}

[[ "$0" == "$BASH_SOURCE" ]] && main
