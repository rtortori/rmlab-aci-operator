# Current Operator version
VERSION ?= 0.0.1
# Default bundle image tag
BUNDLE_IMG ?= controller-bundle:$(VERSION)
# Options for 'bundle-build'
ifneq ($(origin CHANNELS), undefined)
BUNDLE_CHANNELS := --channels=$(CHANNELS)
endif
ifneq ($(origin DEFAULT_CHANNEL), undefined)
BUNDLE_DEFAULT_CHANNEL := --default-channel=$(DEFAULT_CHANNEL)
endif
BUNDLE_METADATA_OPTS ?= $(BUNDLE_CHANNELS) $(BUNDLE_DEFAULT_CHANNEL)

# Image URL to use all building/pushing image targets
IMG ?= controller:latest

#all: docker-build

# Run against the configured Kubernetes cluster in ~/.kube/config
run: ansible-operator
	$(ANSIBLE_OPERATOR) run

# Install CRDs into a cluster
install: kustomize
	$(KUSTOMIZE) build config/crd | kubectl apply -f -

# Uninstall CRDs from a cluster
uninstall: kustomize
	$(KUSTOMIZE) build config/crd | kubectl delete -f -

# Deploy controller in the configured Kubernetes cluster in ~/.kube/config
deploy-k8s: kustomize
	cd config/manager-k8s && $(KUSTOMIZE) edit set image controller=${IMG}
	$(KUSTOMIZE) build config/kubernetes | kubectl apply -f -

# Undeploy controller in the configured Kubernetes cluster in ~/.kube/config
undeploy-k8s: kustomize
	$(KUSTOMIZE) build config/kubernetes | kubectl delete -f -

# Deploy controller in the configured Openshift cluster in ~/.kube/config
deploy-openshift: kustomize
	cd config/manager-openshift && $(KUSTOMIZE) edit set image controller=${IMG}
	$(KUSTOMIZE) build config/openshift | oc apply -f -

# Undeploy controller in the configured Opnshift cluster in ~/.kube/config
undeploy-openshift: kustomize
	$(KUSTOMIZE) build config/openshift | oc delete -f -

# Build the docker image
docker-build:
	docker build . -t ${IMG}

# Push the docker image
docker-push:
	docker push ${IMG}

# Make Kubernetes Installer and Manifests
k8s-installer: kustomize
	$(KUSTOMIZE) build config/crd > manifests/acinamespaces-crd.yaml && \
	$(KUSTOMIZE) build config/rbac-k8s > manifests/acinamespaces-rbac.yaml && \
	$(KUSTOMIZE) build config/manager-k8s > manifests/acinamespaces-controller.yaml && \
	echo "kubectl apply -f ../manifests/acinamespaces-rbac.yaml" > installers/acins-kube-installer.sh && \
	echo "kubectl apply -f ../manifests/acinamespaces-crd.yaml" >> installers/acins-kube-installer.sh && \
	echo "kubectl apply -f ../manifests/acinamespaces-controller.yaml" >> installers/acins-kube-installer.sh
	chmod +x installers/acins-kube-installer.sh

# Make Kubernetes Uninstaller (TODO FIX ORDER)
k8s-uninstaller: kustomize
	$(KUSTOMIZE) build config/crd > manifests/acinamespaces-crd.yaml && \
	$(KUSTOMIZE) build config/rbac-k8s > manifests/acinamespaces-rbac.yaml && \
	$(KUSTOMIZE) build config/manager-k8s > manifests/acinamespaces-controller.yaml && \
	echo "kubectl delete -f ../manifests/acinamespaces-crd.yaml" > installers/acins-kube-uninstaller.sh && \
	echo "kubectl delete -f ../manifests/acinamespaces-controller.yaml" >> installers/acins-kube-uninstaller.sh && \
	echo "kubectl delete -f ../manifests/acinamespaces-rbac.yaml" >> installers/acins-kube-uninstaller.sh
	chmod +x installers/acins-kube-uninstaller.sh

# Make Openshift Installer and Manifests
ocp-installer: kustomize
	$(KUSTOMIZE) build config/crd > manifests/acinamespaces-crd.yaml && \
	$(KUSTOMIZE) build config/rbac-k8s > manifests/acinamespaces-rbac.yaml && \
	$(KUSTOMIZE) build config/manager-k8s > manifests/acinamespaces-controller.yaml && \
	echo "ocp apply -f ../manifests/acinamespaces-rbac.yaml" > installers/acins-ocp-installer.sh && \
	echo "ocp apply -f ../manifests/acinamespaces-crd.yaml" >> installers/acins-ocp-installer.sh && \
	echo "ocp apply -f ../manifests/acinamespaces-controller.yaml" >> installers/acins-ocp-installer.sh
	chmod +x installers/acins-ocp-installer.sh
	
# Make Openshift Uninstaller (TODO FIX ORDER)
ocp-uninstaller: kustomize
	$(KUSTOMIZE) build config/crd > manifests/acinamespaces-crd.yaml && \
	$(KUSTOMIZE) build config/rbac-k8s > manifests/acinamespaces-rbac.yaml && \
	$(KUSTOMIZE) build config/manager-k8s > manifests/acinamespaces-controller.yaml && \
	echo "ocp delete -f ../manifests/acinamespaces-crd.yaml" > installers/acins-ocp-uninstaller.sh && \
	echo "ocp delete -f ../manifests/acinamespaces-controller.yaml" >> installers/acins-ocp-uninstaller.sh && \
	echo "ocp delete -f ../manifests/acinamespaces-rbac.yaml" >> installers/acins-ocp-uninstaller.sh 
	chmod +x installers/acins-ocp-uninstaller.sh

# Dummy test
test: kustomize
	echo "This is a test"

PATH  := $(PATH):$(PWD)/bin
#SHELL := env PATH=$(PATH) /bin/sh
OS    = $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH  = $(shell uname -m | sed 's/x86_64/amd64/')
OSOPER   = $(shell uname -s | tr '[:upper:]' '[:lower:]' | sed 's/darwin/apple-darwin/' | sed 's/linux/linux-gnu/')
ARCHOPER = $(shell uname -m )

kustomize:
ifeq (, $(shell which kustomize 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p bin ;\
	curl -sSLo - https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v3.5.4/kustomize_v3.5.4_$(OS)_$(ARCH).tar.gz | tar xzf - -C bin/ ;\
	}
KUSTOMIZE=$(realpath ./bin/kustomize)
else
KUSTOMIZE=$(shell which kustomize)
endif

ansible-operator:
ifeq (, $(shell which ansible-operator 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p bin ;\
	curl -LO https://github.com/operator-framework/operator-sdk/releases/download/v1.0.0/ansible-operator-v1.0.0-$(ARCHOPER)-$(OSOPER) ;\
	mv ansible-operator-v1.0.0-$(ARCHOPER)-$(OSOPER) ./bin/ansible-operator ;\
	chmod +x ./bin/ansible-operator ;\
	}
ANSIBLE_OPERATOR=$(realpath ./bin/ansible-operator)
else
ANSIBLE_OPERATOR=$(shell which ansible-operator)
endif

# Generate bundle manifests and metadata, then validate generated files.
.PHONY: bundle
bundle: kustomize
	operator-sdk generate kustomize manifests -q
	cd config/manager && $(KUSTOMIZE) edit set image controller=$(IMG)
	$(KUSTOMIZE) build config/manifests | operator-sdk generate bundle -q --overwrite --version $(VERSION) $(BUNDLE_METADATA_OPTS)
	operator-sdk bundle validate ./bundle

# Build the bundle image.
.PHONY: bundle-build
bundle-build:
	docker build -f bundle.Dockerfile -t $(BUNDLE_IMG) .
