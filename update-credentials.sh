#!/bin/sh

# Need to define AWS_DEFAULT_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, S3_URL

TEMP_DOCKER_DIR=/tmp/.docker
TEMP_DOCKER_CONFIG_FILE=$TEMP_DOCKER_DIR/config.json
LOCAL_DOCKER_CONFIG_FILE=~/.docker/config.json
DOCKER_GZ_FILE=/tmp/$CREDENTIALS_FILENAME

if [ ! -f $TEMP_DOCKER_DIR ]
then
  echo "Creating temporary docker credentials directory."
  mkdir -p $TEMP_DOCKER_DIR
fi

source /env/bin/activate

# Login to ECR
aws ecr get-login --region $AWS_DEFAULT_REGION | sh -

if [ ! -f $LOCAL_DOCKER_CONFIG_FILE ]
then
  echo "Error: " $LOCAL_DOCKER_CONFIG_FILE " does not exist.";
else
  echo "Ok: " $LOCAL_DOCKER_CONFIG_FILE " exists.";

  echo "Copy credentials from $LOCAL_DOCKER_CONFIG_FILE to $TEMP_DOCKER_CONFIG_FILE"
  cp $LOCAL_DOCKER_CONFIG_FILE $TEMP_DOCKER_CONFIG_FILE

  if [ ! -f $TEMP_DOCKER_CONFIG_FILE ]
  then
    echo "Error: " $TEMP_DOCKER_CONFIG_FILE " does not exist.";
  else
    echo "Ok: " $TEMP_DOCKER_CONFIG_FILE " exists.";

    tar czf /tmp/$CREDENTIALS_FILENAME -C /tmp .docker

    if [ ! -f $DOCKER_GZ_FILE ]
    then
      echo "Error: " $DOCKER_GZ_FILE " does not exist.";
    else
      aws s3 cp --acl=public-read $DOCKER_GZ_FILE $S3_URL
    fi
  fi

fi

