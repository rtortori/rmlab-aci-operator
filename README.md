# Cisco RMLAB ACI Operator
##### An Ansible operator that extends Kubernetes APIs in order to implement Cisco ACI Automation<br>
Disclaimer: This is NOT an official Cisco application and comes with absolute NO WARRANTY! <br>Please check the [LICENSE](https://github.com/rtortori/rmlab-aci-operator/blob/main/LICENSE-CISCO.md) for further information. <br>

<u>Helm chart repository and instructions [here](https://rtortori.github.io/rmlab-aci-operator-helm/).</u>

### Supported platforms
* Kubernetes v1.16+ (Tested with ACI 4.1, 4.2 and 5.0)
* Openshift Container Platform v4.3+ (Should work but never tested)

<b>Note:</b> The operator uses Volumes. It will NOT start if `docker-novolume-plugin` is used.<br>
<b>Note:</b> This operator now uses `apiextensions.k8s.io/v1beta1` to manage CustomResourceDefinitions. <br>
If you need to run the RMLAB ACI Operator on Kubernetes <1.16 or Openshift 3.x, please use the [v1alpha branch](https://github.com/rtortori/rmlab-aci-operator/tree/v1alpha). However, keep in mind that not all features are available on that release.

### Deployment differences between Kubernetes and Openshift

| Topic        | Kubernetes           | Openshift  |
| ------------- |-------------| -----|
| Resource creation      | Creates a namespace      |   Creates a project |
| Runs on namespace| kube-default      |    aci-containers-system |



### Changelog for Version 1

- The operator now supports multiple use cases to accommodate different business needs
- Controller doesn't have affinity anymore, it will scheduled on any available worker node
- Operator now complies with Operator Framework v1
- Finalizers are now supported for resource cleanup
- Kubectl now shows consumer/provider contracts for the EPG your namespace is attached to. These values are updated by default every 10 seconds
- Option to detach the operator in case at some point in time you want to go manual
- Support for non default AP and Bridge Domain
- Helm installer

## Installation

##### Kubernetes

``` 
helm repo add rmlab-aci-operator https://rtortori.github.io/rmlab-aci-operator-helm/ 
```

``` 
helm install aci-op rmlab-aci-operator/latest 
```

Or you can install manually by cloning this repo and run:

``` 
installers/acins-kube-installer.sh 
```

##### Openshift

``` 
helm repo add rmlab-aci-operator https://rtortori.github.io/rmlab-aci-operator-helm/ 
```

``` 
helm install aci-op rmlab-aci-operator/latest --set global.containerPlatform=openshift 
```

Or you can install manually by cloning this repo and run:

``` 
installers/acins-ocp-installer.sh 
```

<br>
## Uninstall the operator

##### Kubernetes

```
helm unistall aci-op
```

Or you can uninstall manually by cloning this repo and run:

``` 
installers/acins-kube-uninstaller.sh 
```



##### Openshift

```
helm unistall aci-op
```

Or you can uninstall manually by cloning this repo and run:

``` 
installers/acins-ocp-uninstaller.sh 
```

## Features and Operational Model
Compared to previous versions, from version 1 the RMLAB ACI Kubernetes Operator has been reworked to address three challenges:

* Be compliant with the v1 Operator SDK framework data structure and features
* Implement multiple ACI CNI use cases
* Allow the user to detach the operator in case manual (traditional) control is required at some point in time (e.g. you realize the infrastructure is getting too complex to be managed by the operator)

For further information on SDK framework v1, please click [here](https://www.openshift.com/blog/operator-sdk-reaches-v1.0)

The `acinamespaces.rmlab.cisco.com` CRD implements a resource called `AciNamespace` under the API `rmlab.cisco.com/v1`.<br>

While previous versions of this operator only supported a single use case (create an EPG and annotate a namespace), since version 1 the operator supports multiple use cases which can be grouped into two strategies:

1. Provision an ACI EPG and inherit the contracts from an EPG contract master. Create or update a namespace with ACI annotation (Use cases 1, 3 and 8. Described below)<br>
2. Attach to an existing EPG. Create or update a namespace with ACI annotation (Use cases 2, 4 and 6. Described below).<br>

When using strategy no.1. ACI Admins are required to pre-provision EPGs with the right contract as per corporate policies. <br>
Once the EPGs have been defined, Kubernetes admins can reference to their names as EPG Contract Masters (created EPGs will inherit contracts from those EPGs).<br>

The following table describes the operator use cases. Each use case is basically a combination of the specs you can configure in the CR.<br>
 `epgcontractmaster` and `op_managed` are <i>specs</i> of the Custom Resource you create (CR).

| Use Case #        | Use Case Description           | Existing EPG  | epgcontractmaster | op_managed | Notes|
| ------------- |-------------| -----|-----| -----| -----|
| 1| Create a new EPG from an EPG contract master and fully manage the EPG and Namespace. When the AciNamespace is deleted, the EPG and the Namespace will also be deleted | NO | explicit | True | - |
| 2| The EPG will be adopted by the operator, attached to the VMM domain and attached to an EPG contract master. When the AciNamespace is deleted, the EPG and the Namespace will also be deleted | YES | explicit | True | WARNING: You might delete an existing EPG when you remove the CR, ensure this is what you want |
| 3| Create a new EPG from an EPG contract master and fully manage the EPG and Namespace. When the AciNamespace is deleted, the operator is detached and EPG and namespaces will go in manual mode | NO | explicit | False | - |
| 4| The EPG will be adopted by the operator, a bind to the VMM domain will be added and attached to an EPG contract master. When the AciNamespace is deleted, the operator is detached and EPG and namespaces will go in manual mode | YES | explicit | False | - |
| 5| NOT SUPPORTED | NO | not specified in the CR | True | There's no point to create a new EPG with no contracts attached, PODs in this namespace will not work. For this use case, the operator will do NOTHING |
| 6| The EPG will be adopted by the operator and attached to the VMM domain. When the AciNamespace is deleted, the EPG and the Namespace will also be deleted | YES | not specified in the CR | True | WARNING: You might delete an existing EPG when you remove the CR, ensure this is what you want |
| 7| NOT SUPPORTED | NO | not specified in the CR | False | There's no point to create a new EPG with no contracts attached, PODs in this namespace will not work. For this use case, the operator will do NOTHING |
| 8| Create and annotate a Namespace to an existing EPG, adding a VMM binding to it. The operator will still ensure the EPG always exists to be consistent with the Namespace annotation, however, when the AciNamespace is deleted, the operator is detached and both EPG and Namespace will go in manual mode | NO | not specified in the CR | True | - |

The following is a sample Custom Resource (CR) for an `AciNamespace`.

```
apiVersion: rmlab.cisco.com/v1
kind: AciNamespace
metadata:
  name: new-epg-uc1
spec:
  epgcontractmaster: "kube-default"
  openshiftproject: False
  op_managed: True
  
```

The following table describes the `AciNamespaces` Custom Resource (CR) specs.

| Spec        | Description| Example           | Optional/Mandatory  | Default |
| ------------- |-------------| -----|-----|-----|
| epgcontractmaster |The EPG Master Contract you want to attach your EPG to | "kube-default" | Optional | "N/A" |
| openshiftproject | If True, the CR will create/update an Openshift Project | False | Optional | False |
| op_managed | If False, when you delete the CR the operator will detach to the namespace and EPG, allowing you to manually manage the infrastructure | True | **Mandatory** | True |
| applicationprofile | The ACI AP | "kubernetes" | Optional | "kubernetes" |
| bridgedomain | The ACI Bridge Domain | "kube-pod-bd" | Optional | "kube-pod-bd" |
 


### Usage

The folder config/samples contains CR examples for all use cases.<br>

This is an example for Use Case #1:

```
apiVersion: rmlab.cisco.com/v1
kind: AciNamespace
metadata:
  name: frontend
spec:
  epgcontractmaster: "kube-default"
  applicationprofile: "kubernetes"
  bridgedomain: "kube-pod-bd"
  openshiftproject: False
  op_managed: True

```

Where `name` is the desired name of the EPG and Kubernetes namespace<br>

This will:

* Create a new `AciNamespace` resource named `frontend`
* Create a new EPG in the `kubernetes` application profile
* Bind the `frontend` EPG to the VMM domain
* Configure `kube-default` EPG as the contract master for the `frontend` EPG
* Creates or updates a Kubernetes namespace called `frontend` with the correct opflex annotation

## Deployment Example

```
cat <<EOF | kubectl apply -f -
apiVersion: rmlab.cisco.com/v1
kind: AciNamespace
metadata:
  name: frontend
spec:
  epgcontractmaster: "kube-default"
  applicationprofile: "kubernetes"
  bridgedomain: "kube-pod-bd"
  openshiftproject: False
  op_managed: True
EOF
	
acinamespace.rmlab.cisco.com/frontend created
```

```
$ kubectl get acinamespace
NAME       EPG-CONTRACT-MASTER   ACI-BD          MANAGED
frontend   kube-default           kube-pod-bd    true
```

You can fetch more details, like the list of provider and consumer contracts your EPG is using with the "-o wide" option

```
$ k get acinamespace -o wide
NAME       EPG-CONTRACT-MASTER   ACI-BD          M-EPG-C-CONTRACTS                                                                    M-EPG-P-CONTRACTS                       C-CONTRACTS   P-CONTRACTS   MANAGED
frontend   kube-default           kube-pod-bd     [['uni/tn-pvt20/brc-dns', 'uni/tn-pvt20/brc-kube-api', 'uni/tn-pvt20/brc-icmp']]     [['uni/tn-pvt20/brc-health-check']]     []            []           true
```

or using `kubectl describe acinamespace`

```
$ kubectl describe aci frontend
Name:         frontend
Namespace:    default
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"rmlab.cisco.com/v1","kind":"AciNamespace","metadata":{"annotations":{},"name":"frontend","namespace":"default"},"spec":{"ap...
API Version:  rmlab.cisco.com/v1
Kind:         AciNamespace
Metadata:
  Creation Timestamp:  2020-10-17T22:01:09Z
  Finalizers:
    finalizer.aci.rmlab.cisco.com
  Generation:        1
  Resource Version:  1317176
  Self Link:         /apis/rmlab.cisco.com/v1/namespaces/default/acinamespaces/frontend
  UID:               ab7adda3-1313-4266-82d6-d9843ec15831
Spec:
  Applicationprofile:  kubernetes
  Bridgedomain:        kube-pod-bd
  Epgcontractmaster:   kube-default
  op_managed:          true
  Openshiftproject:    false
Status:
  bridge_domain:             kube-pod-bd
  consumer_contracts:        []
  mepg_consumer_contracts:   [['uni/tn-pvt20/brc-dns', 'uni/tn-pvt20/brc-kube-api', 'uni/tn-pvt20/brc-icmp']]
  mepg_dn:                   ['uni/tn-pvt20/ap-kubernetes/epg-kube-default']
  mepg_provider_contracts:   [['uni/tn-pvt20/brc-health-check']]
  provider_contracts:        []
Events:                     <none>
```

This is how the EPG looks in APIC

![alt text](https://raw.githubusercontent.com/rtortori/rmlab-aci-operator/main/screenshots/epg.png "EPGs in ACI")

You can switch mode (Operator managed to unmanaged and viceversa) patching a specific `AciNamespace` at any time 

``` kubectl patch aci youracinamespace -p '{"spec":{"op_managed":false}}' --type=merge ```

Once you delete the CR, if you wish to retake control, you need to recreate the CR. 

## Customization

The operator respects the data structure of the Operator Framework SDK v1.<br>
Please have a look [here](https://sdk.operatorframework.io/docs/building-operators/ansible/quickstart/) for the Ansible operator quick start. <br><br>

To modify the `AciNamespace` CustomResourceDefinition, edit the file `config/bases/rmlab.cisco.com_acinamespaces.yaml`

To modify the controller for Kubernetes (e.g. use your own image), edit the file `config/manager-k8s`
For Openshift, edit the file `config/manager-openshift`

You don't need to modify anything in the `manifests` directory, the manifest files will be created automatically when you build.

The `playbooks` directory contains the main playbook and the finalizer. The playbooks contain descriptions for each task to describe the controller logic.

Modify the `requirements.yaml` file to add more collections to the Ansible controller, in case you want to extend the operator and need additional modules.

The `watches.yaml` file specifies the Kubernetes APIs the controller needs to watch, the playbook it should run, the finalizer that should use when `AciNamespaces` are terminated.
You can customize the reconcilePeriod if you feel 10 seconds is too aggressive.

## Build

Kubernetes (modify the IMG variable with your controller image) 

``` make k8s-installer && make k8s-uninstaller && make docker-build docker-push IMG=your/image:tag ```

Openshift (modify the IMG variable with your controller image)

``` make ocp-installer && make ocp-uninstaller && make docker-build docker-push IMG=IMG=your/image:tag ```
 
