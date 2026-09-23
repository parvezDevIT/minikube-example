#
# Makefile
#
SHELL := /bin/bash # To Fix the issue with the "source" command not being found in the default shell

.EXPORT_ALL_VARIABLES:

#set default ENV based on your username and hostname
APP_DIR=app
TEST_DIR=$(APP_DIR)/test
SRC_DIR=$(APP_DIR)/src
DOCS_DIR=$(APP_DIR)/docs
VENV=hello-world-venv
PROGRAM=run.py
TOUCH_FILES=requirements docs-requirements enable-k8s-ingress 
TEMP_FOLDERS=coverage_html_report $(VENV) $(DOCS_DIR)/build

help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36mmake %-30s\033[0m %s\n", $$1, $$2}'

virtual-env: ## Creates a virtual environment for the python dependencies
	@echo "=========> Creating local python venv"
	python3 -m venv $(VENV)/

requirements: virtual-env ## Install python dependencies
	@echo "=========> Installing Requirements within the created virtual environment"
	( \
		source $(VENV)/bin/activate; \
		pip install -r $(APP_DIR)/requirements.txt; \
		pip install -r $(APP_DIR)/test-requirements.txt; \
    )
	touch $@

docs-requirements: virtual-env ## Install python dependencies
	@echo "=========> Installing Requirements within the created virtual environment"
	( \
		source $(VENV)/bin/activate; \
		pip install -r $(APP_DIR)/docs-requirements.txt; \
    )
	touch $@

html-docs: docs-requirements ## Build html documentation
	@echo "=========> Building HTML documents"
	( \
		source $(VENV)/bin/activate; \
		cd $(DOCS_DIR); \
		make html; \
	)
	echo -e "\033[0;32m**** Documents are now built. run command 'firefox $(DOCS_DIR)/build/html/index.html' to view ****\033[0m"

unittest: virtual-env requirements ## run the unit tests for the app
	@echo "=========> Running Unit Tests"
	( \
		source $(VENV)/bin/activate; \
		PYTHONPATH=$(APP_DIR):$(PYTHONPATH) pytest $(TEST_NAME) ; \
	)

coverage: virtual-env requirements ## generate a coverage report for the unit tests
	@echo "=========> Running Coverage Report"
	( \
		source $(VENV)/bin/activate; \
		PYTHONPATH=$(APP_DIR):$(PYTHONPATH) pytest --cov-report term-missing --cov=src $(TEST_DIR); \
	)

ci: unittest coverage ## unit tests and coverage report in one

docker-image: ## Build a local version of the docker image for testing
	docker build -f ops/docker/hello-world/Dockerfile -t hello-world-test .

docker-stop: ## stop any running docker images from this build and remove ready for rebuild
	docker stop hello-world-test || true
	docker rm hello-world-test || true

container-test: docker-image docker-stop ## build and test the docker image locally
	docker run -d --name hello-world-test -p 5010:5010 hello-world
	curl -s  http://localhost:5010/helloworld | grep -q 'Hello World' && echo -e "\033[0;32m**** Container Test Passed ****\033[0m" || echo -e "\033[0;31m**** Container Test Failed ****\033[0m"

	docker stop hello-world-test
	docker rm hello-world-test

docker-k8s-image: ## Build the k8s image in the minikube docker space so can be referenced in the pod deployment
	eval $$(minikube docker-env) && \
	docker ps && \
	docker build -f ops/docker/hello-world/Dockerfile -t hello-world-test . && \
	docker ps 

enable-k8s-ingress: ## enable ingress addon in minikube
	minikube addons enable ingress
	touch $@

deploy-k8s-service: docker-k8s-image enable-k8s-ingress ## deploy out all the minikube resources
	kubectl apply -f ops/kubernetes/hello-world-deployment.yml
	kubectl apply -f ops/kubernetes/hello-world-service.yaml
	kubectl apply -f ops/kubernetes/hello-world-ingress.yaml

	@echo -e "\033[0;32m**** Dozing for a few while the services start .... ****\033[0m"
	sleep 30s
	minikube ip
	$(eval IP=$(shell minikube ip))
	curl -s -I -H "Host: hello.world" http://$(IP)/helloworld | grep "200 OK" && echo -e "\033[0;32m**** K8s deploy Success ****\033[0m" || echo -e "\033[0;31m**** K8s Service deploy Failed ****\033[0m" 

clean-k8s-service: ## clean the minikube resources
	kubectl delete -f ops/kubernetes/hello-world-deployment.yml || true
	kubectl delete -f ops/kubernetes/hello-world-service.yaml || true
	kubectl delete -f ops/kubernetes/hello-world-ingress.yaml || true

clean: clean-k8s-service docker-stop ## clean everything up
	-rm $(TOUCH_FILES)
	-rm -Rf $(TEMP_FOLDERS)
	docker rmi hello-world-test || true


.PHONY: help clean clean-k8s-service unittest coverage docker-image docker-stop container-test docker-k8s-image deploy-k8s-service  
