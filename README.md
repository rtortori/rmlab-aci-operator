# Cisco RMLAB ACI Operator
##### An operator that extends Kubernetes APIs allowing for automatic EPG and annotated namespace creation<br>
Disclaimer: This is NOT an official Cisco application and comes with absolute NO WARRANTY! <br>Please check LICENSE-CISCO.md for further information <br>

### Supported platforms
* Kubernetes v1.11.3+ (Tested with ACI 4.1, 4.2)
* Openshift Container Platform v3.11+ (Tested with ACI 4.1)

<b>Note:</b> the operator uses Volumes. It will NOT start if `docker-novolume-plugin` is used.

### Differences between Kubernetes and Openshift

| Topic        | Kubernetes           | Openshift  |
| ------------- |-------------| -----|
| Scheduling      | Required to run on any master node | Preferred on master nodes |
| Resource creation      | Creates a namespace      |   Creates a project |
| Runs on namespace| kube-default      |    aci-containers-system |


### Installation
Kubernetes

``` ./install-operator-kubernetes.sh```

Openshift

``` ./install-operator-openshift.sh```

### Operational Model
The CRD implements a new resource called `AciNamespace` under the API `rmlab.cisco.com/v1alpha2`.<br>

ACI Admins are required to pre-provision EPGs with the right contract as per corporate policies. <br>
Once the EPGs have been defined, Kubernetes admins can reference to their names as EPG Contract Masters (created EPGs will inherit contracts from those EPGs).<br>

The operator works for Kubernetes and Openshift. During the CR creation, the user needs to specify whether this is a Kubernetes or Openshift cluster, in case the `openshiftProject` spec is `True`, the operator will create a Project instead of a Namespace.

### Usage

AciNamespace creation YAML:

```
apiVersion: rmlab.cisco.com/v1alpha2
kind: AciNamespace
metadata:
  name: frontend
spec:
  epgContractMaster: "kube-default"
  openshift_project: False
```

Where:<br>
`name` is the desired name of the EPG and Kubernetes namespace<br>
`epgContractMaster` is the EPG contract master name<br>
`openshiftProject` is a boolean that instructs the operator whether to create an Openshift project, instead of a Namespace
`aciCleanup` is a boolean that allows for ACI cleanup if the object is deleted. Note that as of today, this is currently not implemented and this spec has been added in preparation for the feature to happen

This will:

* Create a new `AciNamespace` resource named `frontend`
* Create a new EPG in the `kubernetes` application profile
* Bind the `frontend` EPG to the VMM correct domain
* Configure `kube-default` EPG as the contract master for the `frontend` EPG
* Create a Kubernetes namespace or Openshift project called `frontend` with the correct opflex annotation

#### Example
```
cat <<EOF | kubectl apply -f -
apiVersion: rmlab.cisco.com/v1alpha2
kind: AciNamespace
metadata:
  name: backend
spec:
  epgContractMaster: "kube-default"
  openshiftProject: False
  aciCleanup: False
EOF
	
acinamespace.rmlab.cisco.com/backend created
```

```
~@ccp$ kubectl get acinamespace
NAME       AGE
backend    2m
frontend   1h
```

```
~@ccp$ kubectl describe namespace frontend
Name:         frontend
Labels:       controller=ACI-Operator
Annotations:  operator-sdk/primary-resource: /frontend
              operator-sdk/primary-resource-type: AciNamespace.rmlab.cisco.com
              opflex.cisco.com/endpoint-group:  {"tenant":"rtortori_operator","app-profile":"kubernetes","name":"frontend"}
Status:       Active

No resource quota.

No resource limits.
```

![alt text](https://raw.githubusercontent.com/rtortori/rmlab-aci-operator/master/screenshots/epg.png "EPGs in ACI")

#### TODO
- add build instructions
- add cleanup finalizer to watches.yaml to selectively remove namespaces and EPG if can_delete is 'true'
- decouple ACI objects into a dedicated CRD (i.e. aciepg, acicontract, etc.)
