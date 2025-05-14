# Features

This template provides the following features

## Automated PR testing

Any time a PR is opened for the repo, then the [Docker Build and Publish](./.github/workflows/docker-build-publish.yaml)
workflow gets kicked off and validates [linting](#linting) of source files, and [building](#docker-build) of the Dockerfile.

## GitHub Container Registry Publishing

Docker images are published to the GitHub container registry for this repo under the following circumstances:

- new commit on the `main` branch
- new [semantic version](https://semver.org/) tag is pushed to the repo

Under both of these circumstances, the whole [Docker Build and Publish](./.github/workflows/docker-build-publish.yaml)
workflow is executed, and only on success is the corresponding tag in the registry either created or updated.

Publishing to the registry is provided by the [docker/build-push-action](https://github.com/docker/build-push-action)
GitHub action.

When a semantic version tag is published to the registry, then a
[GitHub Release](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases) is also automatically
created in the repo.

## Automated GitHub Release Creation

In order to automate creating new releases in the GitHub repo, the
[softprops/action-gh-release](https://github.com/softprops/action-gh-release) GitHub action is used.

Furthermore, the release notes for the release are automatically created from completed PRs in the repo.  This is done
according to the
[GitHub automatic release notes](https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes)
feature, and the configuration in this repo found at [./.github/release.yml](./.github/release.yml).  Using the correct
tags on PRs will put them into the appropriate section of the automatically generated release notes.

## Makefile driven local testing

All supported testing can be easily driven locally with simple `make` commands.

To run all checks that a PR runs:

```bash
make ready
```

To just run [linting](#linting)

```bash
make lint
```

To jus run the [docker build](#docker-build)

```bash
make build
```

## Docker Build

The `make build` target will build the docker image locally, tag it with a [dirty tag](#docker-dirty-tag) and then run
CI efficiency checks on the created image with [dive](https://github.com/wagoodman/dive)

When the local docker build runs, it also should tag it with the same full image that that would exist as when the image
is [published to the GitHub container registry](#github-container-registry-publishing).  The way it figures out this
name is by parsing the value of `remote.origin.url` in the current git repo workspace.  This should work as long as
you've cloned the repo using `https` or `ssh` from GitHub.  If you did something different, then this may not work and
you should review the section of the makefile that does this parsing.  You would know it's not working properly because
`make build` wouldn't be creating appropriate image names for the image you are building.

### Docker dirty tag

In order to differentiate locally built images from those built in CI we create a `dirty` tag to tag the built image
with.  This tag is created using the following format:

`WHOAMI-GITDESCRIBE-dirty`

Where `WHOAMI` is the output from `whoami` which is the current username, and `GITDESCRIBE` is the output of
`git describe --always`.

## Linting

Any good software CI setup includes fast and helpful linting.  To that end, we provide plenty of it setup in this repo.

### Dockerfile Linting

Linting of the Dockerfile is provided via [hadolint](https://github.com/hadolint/hadolint)

### Markdown Linting

Linting of all markdown files is provided by [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli)

### YAML Linting

Linting of all YAML files is provided by [pipelinecomponents/yamllint](https://hub.docker.com/r/pipelinecomponents/yamllint)
