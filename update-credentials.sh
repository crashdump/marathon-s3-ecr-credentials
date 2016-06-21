#!/bin/sh

if [[ -z "$AWS_DEFAULT_REGION" || -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" || -z "$S3_URL" ]]; then
    echo "This script requires AWS_DEFAULT_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and S3_URL env variables."
    exit 1
fi

TEMP_DOCKER_DIR=/tmp/.docker
TEMP_DOCKER_CONFIG_FILE=$TEMP_DOCKER_DIR/config.json
LOCAL_DOCKER_CONFIG_FILE=~/.docker/config.json
DOCKER_GZ_FILE=/tmp/docker-config.tar.gz

if [ ! -f $TEMP_DOCKER_DIR ]
then
  echo "Creating temporary docker credentials directory."
  mkdir -p $TEMP_DOCKER_DIR
fi

source /env/bin/activate

# Login to ECR
eval $(aws ecr get-login --region $AWS_DEFAULT_REGION)

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

    tar czf /tmp/docker-config.tar.gz -C /tmp .docker

    if [ ! -f $DOCKER_GZ_FILE ]
    then
      echo "Error: " $DOCKER_GZ_FILE " does not exist.";
    else
      aws s3 cp --acl=public-read $DOCKER_GZ_FILE $S3_URL
    fi
  fi

fi

