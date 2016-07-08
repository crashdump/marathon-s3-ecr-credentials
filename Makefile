repository_name=crashdump
container_name=marathon-s3-ecr-credentials

all: build

build:
	docker build -t $(repository_name)/$(container_name) .
	docker tag $(repository_name)/$(container_name) $(repository_name)/$(container_name):$(shell cat VERSION)
	docker tag $(repository_name)/$(container_name) $(repository_name)/$(container_name):latest

push:
	docker push $(repository_name)/$(container_name):$(shell cat VERSION)
