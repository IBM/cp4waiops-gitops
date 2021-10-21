<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [cp4waiops-gitops](#cp4waiops-gitops)
  - [Prerequisite](#prerequisite)
    - [Platform Requirements](#platform-requirements)
    - [Config Gitops and Crossplane Provider on OCP](#config-gitops-and-crossplane-provider-on-ocp)
      - [Login to openshift and grant argocd enough permissions](#login-to-openshift-and-grant-argocd-enough-permissions)
      - [login to ArgoCD](#login-to-argocd)
      - [Install CP4WAIOPS Provider](#install-cp4waiops-provider)
  - [Deploy Cloud Paks](#deploy-cloud-paks)
    - [Scenario 1: Install cp4waiops in an provided ocp cluster](#scenario-1-install-cp4waiops-in-an-provided-ocp-cluster)
    - [Scenario 2: Install instana in k8s cluster](#scenario-2-install-instana-in-k8s-cluster)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# cp4waiops-gitops

- This is a playground for gitops and crossplane integration.
- The first attemp is installing cloudpak in a simple way, start from CP4WAIOPS.
- The crossplane provider repo : https://github.com/cloud-pak-gitops/crossplane-provider-cp4waiops
- Refer to [OpenShift GtiOps](https://www.openshift.com/blog/announcing-openshift-gitops) for some configuration to enable GitOps on OCP.

## Prerequisite

### Platform Requirements

- OCP 4.6 + 
- Install gitops operator in ocp operator-hub
- Install crossplane operator in ocp operator-hub 
### Config Gitops and Crossplane Provider on OCP

#### Login to openshift and grant argocd enough permissions

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: argocd-admin
subjects:
  - kind: ServiceAccount
    name: argocd-cluster-argocd-application-controller
    namespace: openshift-gitops
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
```

#### login to ArgoCD

TODO

#### Install CP4WAIOPS Provider

```
REPO URL : https://github.com/cloud-pak-gitops/cp4waiops-gitops
Target version: HEAD
path: crossplane
Namespace: upbound-system
```

## Deploy Cloud Paks

### Scenario 1: Install cp4waiops in an provided ocp cluster 

Create a secret storing target ocp cluster kubeconfig :
```shell
kubectl create secret generic openshift-cluster-kubeconfig --from-file=credentials=./<kubeconfig-file> -n crossplane-system
```

**Note:** please replace the kubeconfig to your real file


Create a ArgoCD application for installing cp4aiops in provided ocp 
```
REPO URL : https://github.com/cloud-pak-gitops/cp4waiops-gitops
Target version: HEAD
path: cp4waiops
Namespace: upbound-system
```

### Scenario 2: Install instana in k8s cluster
Create a secret storing target k8s cluster kubeconfig :
```shell
kubectl create secret generic k8s-kubeconfig --from-file=credentials=./<kubeconfig-file> -n crossplane-system
```

Create a ArgoCD application for installing cp4aiops in provided ocp 
```
REPO URL : https://github.com/cloud-pak-gitops/cp4waiops-gitops
Target version: HEAD
path: instana
Namespace: upbound-system
```