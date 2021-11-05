<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Deploy cloudpak - incluster](#deploy-cloudpak---incluster)
  - [Prerequisite](#prerequisite)
    - [Platform Requirements](#platform-requirements)
  - [Install Infra (Crossplane and Crossplane Instana Provider)](#install-infra-crossplane-and-crossplane-instana-provider)
    - [Login to openshift and grant argocd enough permissions**](#login-to-openshift-and-grant-argo-cd-enough-permissions)
    - [Login to Argo CD](#login-to-argo-cd)
    - [Install CP4WAIOPS Provider](#install-cp4waiops-provider)
    - [Verify Crossplane Provider](#verify-crossplane-provider)
      - [CLI Verify](#cli-verify)
      - [UI Verify](#ui-verify)
    - [Storage consideration](#storage-consideration)
  - [Deploy Cloud Paks](#deploy-cloud-paks)
    - [Create a secret storing your entitlement key:](#create-a-secret-storing-your-entitlement-key)
    - [Create a secret storing target ocp cluster kubeconfig :](#create-a-secret-storing-target-ocp-cluster-kubeconfig-)
    - [Create a ArgoCD application for installing cp4waiops in-cluster](#create-a-argocd-application-for-installing-cp4waiops-in-cluster)
  - [Verify Cloud Paks Installation](#verify-cloud-paks-installation)
      - [CLI Verify](#cli-verify-1)
      - [UI Verify](#ui-verify-1)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Deploy cloudpak - incluster

## Prerequisite

### Platform Requirements

- OCP 4.6 + 
- Install gitops operator(Red Hat OpenShift GitOps) in ocp operator-hub
- Install crossplane operator(Upbound Universal Crossplane (UXP)) in ocp operator-hub

## Install Infra (Crossplane and Crossplane CP4WAIOps Provider)

### Login to openshift and grant argocd enough permissions**

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: argocd-admin
subjects:
  - kind: ServiceAccount
    name: openshift-gitops-argocd-application-controller
    namespace: openshift-gitops
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
```

### Login to ArgoCD

Login ArgoCD entrance

![Login entrance](./images/ArgoCD-Interface.png)   

Login Username/Password
```
Username: admin  
Password: Please copy the Data value of secret "openshift-gitops-cluster" in namespace "openshift-gitops"
```

![Secret data](./images/login-argocd-user-pass.png) 

### Install CP4WAIOPS Provider

Create application.  
Choose "New App" in "Applications".  
Fill in like below, then choose "create". 

```
GENERAL
Application Name: anyname(like "crossplane-provider")
Project: default
SYNC POLICY: Automatic

SOURCE
REPO URL : https://github.com/cloud-pak-gitops/cp4waiops-gitops
Target version: HEAD
path: config/argocd-apps/infra

DESTINATION
Cluster URL: https://kubernetes.default.svc
Namespace: upbound-system

HELM
metadata.argocd_app_namespace: openshift-gitops
metadata.cp4waiops_provider_namespace: upbound-system
metadata.crossplane_namespace: upbound-system
repoURL: https://github.com/cloud-pak-gitops/instana-gitops
```

### Verify Crossplane Provider

#### CLI Verify

TODO

#### UI Verify

TODO

### Storage consideration 

It depends where the OCP comes from , if you're using fyre , then could create gitops application

```
GENERAL
Application Name: ceph
Project: default
SYNC POLICY: Automatic

SOURCE
REPO URL : https://github.com/cloud-pak-gitops/cp4waiops-gitops
Target version: HEAD
path: ceph

DESTINATION
Cluster URL: https://kubernetes.default.svc
Namespace: rook-ceph
DIRECTORY
DIRECTORY RECURSE: tick it
```

## Deploy Cloud Paks

### Create a secret storing your entitlement key:

```
kubectl create secret generic image-pull-secret --from-literal=cp.icr.io=cp:<entitlement-key> -n crossplane-system
```

**Note:** refer to [CP4WAIOPS-KC](https://www.ibm.com/docs/en/cloud-paks/cp-waiops/3.1.0?topic=installing-preparing-install-cloud-pak#entitlement_keys) to replace the `entitlement-key` 

### Create a secret storing target ocp cluster kubeconfig :

```
kubectl create secret generic openshift-cluster-kubeconfig --from-file=credentials=<kubeconfig> -n crossplane-system
```

**Note:** please replace the kubeconfig to your real file , default value : /root/.kube/config


### Create a ArgoCD application for installing cp4waiops in-cluster

```
GENERAL
Application Name: anyname(like "cp4waiops")
Project: default
SYNC POLICY: Automatic

SOURCE
REPO URL : https://github.com/cloud-pak-gitops/cp4waiops-gitops
Target version: HEAD
path: config/cp4waiops

DESTINATION
Cluster URL: https://kubernetes.default.svc
Namespace: upbound-system

HELM
spec.cp4waiops_namespace: cp4waiops
spec.channel: v3.1
spec.imageCatalog: icr.io/cpopen/aiops-orchestrator-catalog:3.1-latest
spec.imagePullSecret: image-pull-secret
spec.kubeConfigSecretName: openshift-cluster-kubeconfig
spec.kubeConfigSecretNS: crossplane-system
spec.providerConfigRef: openshift-cluster-provider-config 
spec.storageClass: rook-cephfs
spec.storageClassLargeBlock: rook-cephfs
```

## Verify Cloud Paks Installation

### CLI Verify

TODO

### UI Verify

TODO