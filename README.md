# Hello World minikube Example

An example of how to automate a minikube build, test and deployment.

This project contains all the resources and code required to:

1. Build and unit test a basic "Hello World!" flask app.
2. Report the code coverage of the testing
3. Build supporting documentation
4. Build the flask app into a deployable container
5. Deploy the container and routing to `minikube`
6. Test the container build locally and deployed to `minikube`

No system files were harmed during the making of this demonstration, but it does contain a fully working and operational ---battle station--- ... sorry minikube deployment.

## Dependencies

1. Installed and working docker environment
2. Installed and working minikube environment
3. Python
4. User access to all above resources, no `sudo` required or coded for. So user must be in the `docker` group.
5. GNU Make (usually installed with dev tools on a linux machine). The project was built and tested with `GNU Make 4.3`

Software versions tested with

- `minikube` - v1.17.1
- `kubectl` - v1.20.2 (server and client)
- `docker` - 20.10.2
- `python` - 3.7.2

The solution will build and configure its own virtual environment so no preparatory work required. The Makefile macros take care of all this.

## Folder Structure

```text
.
├── app
│   ├── docs
│   │   ├── api-specification
│   │   └── source
│   │       ├── _static
│   │       └── _templates
│   ├── src
│   └── test
├── config
│   ├── apache
│   └── wsgi
└── ops
    ├── docker
    │   └── hello-world
    └── kubernetes

```

## Files of note

- `/app/src/run.py` The actual executable Flask API answering on `/helloworld`
- `/app/docs/source/*.rst` Documentation skeleton for the project
- `/app/docs/api-specification/helloworld.yaml` OpenAPI specification for the Flask hello world endpoints
- `/ops/docker/hello-world/Dockerfile` Container build (see TODO notes at the end for further optimisations required here)
- `/ops/kubernetes/*.yml` Definition files for the kubernetes resources. Deployments, Service and Ingress
- `/app/test/test_*` Test files for unit testing the source code
- `/app/*requirements.txt` Python dependency files for the app, test and documentation
- `.coveragerc` rules for coverage report for unit tests
- `Makefile` The brains of the operation, all the automation macros to build, test and deploy the solution.

## Order of Execution

1. `make unittest` - runs the unit test framework
2. `make coverage` - runs a coverage report for unit testing and outputs to terminal
3. `make container-test` - builds a local docker image and tests the container endpoint
4. `make deploy-k8s-service` - Builds and deploys the required images and services to minikube

For a shortcut `make deploy-k8s-service` can be run independently and will just build and deploy with no testing

## For the curious

`make html-docs` - Will produce a set of documentation of the code and the API spec that can be deployed to a support portal during CI/CD

## Makefile Macros

The Makefile is self documenting so just run `make` and it will provide the list of available macros

- `make ci` Unit tests and coverage report in one
- `make clean` Clean everything up
- `make clean-k8s-service` Clean the minikube resources
- `make container-test` Build and test the docker image locally
- `make coverage` Generate a coverage report for the unit tests
- `make deploy-k8s-service` Deploy out all the minikube resources
- `make docker-image` Build a local version of the docker image for testing
- `make docker-k8s-image` Build the k8s image in the minikube docker space so can be referenced in the pod deployment
- `make docker-stop` Stop any running docker images from this build and remove ready for rebuild
- `make requirements` Install python dependencies
- `make unittest` Run the unit tests for the app
- `make virtual-env` Creates a virtual environment for the python dependencies
- `make enable-k8s-ingress` Enable ingress addon in minikube
- `make docs-requirements` Install python dependencies
- `make html-docs` Build html documentation

## Cleaning up

To clean the environment after review `make clean` will remove the minikube resources and any temporary files (virtual env, etc) from the local machine

## TODO

1. Optimise the docker image, could potentially use a more efficient image for production
2. Add in more documentation about the deployed configuration code
3. `make clean` tidy up to remove all python compiled files
