# Cisco RMLAB ACI Operator
#####An operator that extends Kubernetes APIs allowing for automatic EPG and annotated namespace creation 
######Disclaimer: This is NOT an official Cisco application and comes with absolute NO WARRANTY! <br>Please check LICENSE-CISCO.md for further information <br>

#### Supported platforms
* Kubernetes v1.11.3+ 
* Openshift Container Platform v3.11+

#### Installation
Kubernetes

``` ./install-operator-kubernetes.sh```

Openshift

``` ./install-operator-openshift.sh```

#### Operational Model
The CRD implements a new resource called `AciNamespace` under the API `rmlab.cisco.com/v1alpha1`.<br>

ACI Admins are required to pre-provision EPGs with the right contract as per corporate policies. <br>
Once the EPGs have been defined, Kubernetes admins can reference to their names as EPG Contract Masters (created EPGs will inherit contracts from those EPGs).<br>

#### Usage

AciNamespace creation YAML:

```
apiVersion: rmlab.cisco.com/v1alpha1
kind: AciNamespace
metadata:
  name: frontend
spec:
  epgcontractmaster: "kube-default"
```

Where:<br>
`name` is the desired name of the EPG and Kubernetes namespace<br>
`epgcontractmaster` is the EPG contract master name

This will:

* Create a new `AciNamespace` resource named `frontend`
* Create a new EPG in the `kubernetes` application profile
* Bind the `frontend` EPG to the VMM correct domain
* Configure `kube-default` EPG as the contract master for the `frontend` EPG
* Create a Kubernetes namespace called `frontend` with the correct opflex annotation

##### Example
```
cat <<EOF | kubectl apply -f -
apiVersion: rmlab.cisco.com/v1alpha1
kind: AciNamespace
metadata:
  name: backend
spec:
  epgcontractmaster: "kube-default"
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