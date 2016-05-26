# marathon-s3-ecr-credentials
Docker container to periodically update the Credentials for an AWS Elastic Container Registry and upload to S3 for Mesosphere Marathon

# Marathon S3 ECR Credentials Updater

This is Docker container that when executed will update the Docker registry credentials and upload to S3 for an Amazon Elastic Container Registry.

## Why is this needed?

Because access to ECR is controlled with AWS IAM.
An IAM user must request a temporary credential to the registry using the AWS API.
This temporary credential is then valid for 12 hours.

Marathon requires docker credentials to be downloaded for private registries.

## How to use

Run this container with the following environment variables:
* `AWS_DEFAULT_REGION` - the AWS region of the ECR registry
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `S3_URL` - the url to the s3 bucket that will contain the docker credentials (i.e. s3://my-s3-bucket/)

## Running Credentials Updater in Marathon

You should start one instance of this service in Marathon.

Example ```config.json```:
```
{
  "container": {
    "type": "DOCKER",
    "volumes": [
      {
        "containerPath": "/var/run/docker.sock",
        "hostPath": "/var/run/docker.sock",
        "mode": "RO"
      }
    ],
    "docker": {
      "network": "BRIDGE",
      "image": "joe1chen/marathon-s3-ecr-credentials:latest",
      "privileged": true
    }
  },
  "id": "marathon-s3-ecr-credentials",
  "instances": 1,
  "cpus": 0.01,
  "mem": 128,
  "disk": 200,
  "env": {
    "AWS_DEFAULT_REGION": "us-east-1",
    "AWS_ACCESS_KEY_ID": "XXX",
    "AWS_SECRET_ACCESS_KEY": "YYY",
    "S3_URL": "s3://my-s3-bucket/",
    "CREDENTIALS_FILENAME": "docker-config.tar.gz"
  }
}
```

## Running container manually

```bash
$ docker run -d -v /var/run/docker.sock:/var/run/docker.sock -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e S3_URL=s3://my-s3-bucket/ -e CREDENTIALS_FILENAME=docker-config.tar.gz joe1chen/marathon-s3-ecr-credentials:latest
```

## Downloading the credentials when deploying private apps

Updated ECR credentials are uploaded to the s3 url with the filename $CREDENTIALS_FILENAME.
Add the S3 download url to the ```uris``` section of your marathon configuration.

```
  "uris":  [
    "https://s3.amazonaws.com/my-s3-bucket/docker-config.tar.gz"
  ]
```

## Notes

The AWS credentials must correspond to an IAM user that has permissions to call the ECR `GetToken` API as well as upload to S3 url specified.

__NOTE__: This application runs on a 1 hour loop.