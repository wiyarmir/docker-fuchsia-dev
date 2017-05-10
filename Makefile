default: build

# Build Docker image
build: docker_build output

# Build and push Docker image
release: docker_build docker_push output

DOCKER_IMAGE ?= wiyarmir/fuchsia

ifeq (x$(DOCKER_IMAGE), x)
$(error echo You need to tag your build somehow)
endif

# Get the latest commit.
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

docker_build:
	echo `pwd`
	docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VCS_URL=`git config --get remote.origin.url` \
  --build-arg VCS_REF=$(GIT_COMMIT) \
  -t $(DOCKER_IMAGE) .
	
docker_push:
	# Tag image as latest
	docker tag $(DOCKER_IMAGE)

	# Push to DockerHub
	docker push $(DOCKER_IMAGE)

output:
	@echo Docker Image: $(DOCKER_IMAGE) @ $(GIT_COMMIT)
