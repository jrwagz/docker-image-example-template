
# These variables are used for controlling how the image gets tagged when it's built, and they can be overridden when
# the call to the make command is made
IMAGE_NAME = ghcr.io/jrwagz/docker-image-example-template

# Here we default to an image tag that makes it obvious that it was a local build, and that it isn't coming from CI
IMAGE_TAG:=$(shell whoami)-$(shell git describe --always)-dirty

# These variables control what images and tags are used for the various linting tasks
MD_LINT_IMAGE:=ghcr.io/igorshubovych/markdownlint-cli:v0.44.0
DOCKERFILE_LINT_IMAGE:=ghcr.io/hadolint/hadolint:v2.12.0
DIVE_IMAGE:=ghcr.io/wagoodman/dive:v0.13.1
YAML_LINT_IMAGE:=pipelinecomponents/yamllint:0.34.0

IS_TTY := $(shell [ -t 0 ] && echo yes || echo no)
ifeq ($(IS_TTY),yes)
TTY_ARGS := "-it"
else
TTY_ARGS := "-i"
endif


.PHONY: build
build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	docker run --rm $(TTY_ARGS) \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v  "$(PWD)":"$(PWD)" \
      -w "$(PWD)" \
	  -e CI=true \
      $(DIVE_IMAGE) $(IMAGE_NAME):$(IMAGE_TAG)
	@echo SUCCESS $(FULL_NAME):$(IMAGE_TAG) is built and has been scanned by dive

MD_FILES:=$(shell find . -name "*.md")
.PHONY: lint_markdown
lint_markdown:
	docker run --rm $(TTY_ARGS) \
		-v "${PWD}":"${PWD}" \
		-w "${PWD}" \
		$(MD_LINT_IMAGE) $(MD_FILES)

.PHONY: lint_dockerfile
lint_dockerfile:
	docker run --rm -i \
		$(DOCKERFILE_LINT_IMAGE) < Dockerfile

.PHONY: lint_yaml
lint_yaml:
	docker run --rm $(TTY_ARGS) \
		-v "$(PWD)":"$(PWD)" \
		-w "$(PWD)" \
		$(YAML_LINT_IMAGE) yamllint -c .yamllint.yaml .


# Aliases
.PHONY: lint
lint: lint_dockerfile lint_markdown lint_yaml
.PHONY: ready
ready: lint build