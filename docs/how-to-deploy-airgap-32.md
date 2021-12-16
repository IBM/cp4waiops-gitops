<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Deploy Cloud Pak for Watson AIOps with OpenShift GitOps](#deploy-cloud-pak-for-watson-aiops-with-openshift-gitops)
  - [Prerequisite](#prerequisite)
  - [Install CP4WAIOPS](#install-cp4waiops)
    - [Option 1: Using the OCP console](#option-1-using-the-ocp-console)
      - [1. Grant Argo CD Enough Permissions](#1-grant-argo-cd-enough-permissions)
      - [2. Login to Argo CD](#2-login-to-argo-cd)
      - [3. Storage Consideration](#3-storage-consideration)
      - [4. Create a ArgoCD application for installing cp4waiops in-cluster](#4-create-a-argocd-application-for-installing-cp4waiops-in-cluster)
    - [Option 2: Using a terminal](#option-2-using-a-terminal)
      - [1. Grant Argo CD Enough Permissions](#1-grant-argo-cd-enough-permissions-1)
      - [2. Login to the Argo CD server](#2-login-to-the-argo-cd-server)
      - [3. Storage Consideration](#3-storage-consideration-1)
      - [4. Create a ArgoCD application for installing cp4waiops in-cluster](#4-create-a-argocd-application-for-installing-cp4waiops-in-cluster-1)
    - [Verify Cloud Paks Installation](#verify-cloud-paks-installation)
      - [CLI Verify](#cli-verify)
      - [UI Verify](#ui-verify)
    - [Access CP4WAIOps UI](#access-cp4waiops-ui)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Deploy Cloud Pak for Watson AIOps with OpenShift GitOps

If your cluster is not connected to the internet, you can complete a production install of IBM Cloud Pak® for Watson AIOps AI Manager in your cluster by using a bastion host. (portable compute device, or portable storage device will be supported later)

## Prerequisite

- You must prepare a bastion host that can connect to the internet and to the air-gapped network with access to the Red Hat® OpenShift® Container Platform cluster and the local, intranet Docker registry.
- Your host must have 120GB storage to hold all of the software that is to be transferred to the local, intranet Docker registry.
- Install gitops operator(Red Hat OpenShift GitOps) in ocp operator-hub
- Local image registry and access
- OCP 4.8 to install CP4WAIops

## Install CP4WAIOPS

### Option 1: Using the OCP console

#### 1. Grant Argo CD Enough Permissions

From the Red Hat OpenShift OLM UI, go to **User Management** > **RoleBindings** > **Create binding**.

Use the Form view to configure the properties for the **ClusterRoleBinding**, and select the Create button.

```
Binding type: Cluster-wide role binding (ClusterRoleBinding)

RoleBinding
Name: argocd-admin

Role
Role Name: cluster-admin

Subject
ServiceAccount:  tick it
Subject namespace: openshift-gitops
Subject name: openshift-gitops-argocd-application-controller
```

#### 2. Login to Argo CD

Login ArgoCD entrance

![Login entrance](./images/ArgoCD-Interface.png)   

Login Username/Password
```
Username: admin  
Password: Please copy the Data value of secret "openshift-gitops-cluster" in namespace "openshift-gitops"
```

You can use following command to get the password:

```
oc get secret openshift-gitops-cluster -n openshift-gitops -ojsonpath='{.data.admin\.password}' | base64 -d; echo
```

![Secret data](./images/login-argocd-user-pass.png) 

#### 3. Storage Consideration

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

#### 4. Create a ArgoCD application to mirror image to host local registry

```
GENERAL
Application Name: anyname(like "imagemirror")
Project: default
SYNC POLICY: Automatic

SOURCE
REPO URL : https://github.com/cloud-pak-gitops/cp4waiops-gitops
Target version: HEAD
path: config/3.2/airgap/imageMirror

DESTINATION
Cluster URL: https://kubernetes.default.svc
Namespace: image

HELM
spec.imageMirror_namespace: image
spec.localDockerRegistryHost: <localDockerRegistryHost>
spec.localDockerRegistryPort: <localDockerRegistryPort>
spec.localDockerRegistryUser: <localDockerRegistryUser>
spec.localDockerRegistryPassword: <localDockerRegistryPassword>
spec.cpRegistryPassword: <entitlement-key>
spec.aiManager.enabled: false  ## set to true if you want to install AIManager
spec.aiManager.caseName: ibm-cp-waiops
spec.aiManager.caseVersion: 1.1.0
spec.aiManager.redhatRegistryUser: <redhatRegistryUser>
spec.aiManager.redhatRegistryPassword: <redhatRegistryPassword>
spec.eventManagerGateway.enabled: ## set to true if you want to install EvetMangerGateway
spec.eventManagerGateway.caseName: ibm-netcool-prod
```

Where:

- <entitlement-key> is the entitlement key that you copied in [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary)


Connect your host to your air-gapped environment and connet your OCP to the gitops.

#### 5. Create a ArgoCD application for installing cp4waiops

```
GENERAL
Application Name: anyname(like "cp4waiops")
Project: default
SYNC POLICY: Automatic

SOURCE
REPO URL : https://github.com/cloud-pak-gitops/cp4waiops-gitops
Target version: HEAD
path: config/3.2/cp4waiops

DESTINATION
Cluster URL: <your airgap OCP cluster>
Namespace: cp4waiops

HELM
spec.cp4waiops_namespace: cp4waiops
spec.localDockerRegistryHost: <localDockerRegistryHost>
spec.localDockerRegistryPort: <localDockerRegistryPort>
spec.localDockerRegistryUser: <localDockerRegistryUser>
spec.localDockerRegistryPassword: <localDockerRegistryPassword>
spec.storageClass: rook-cephfs
spec.storageClassLargeBlock: rook-cephfs
spec.aiManager.enabled: false  ## set to true if you want to install AIManager
spec.aiManager.caseName: ibm-cp-waiops
spec.aiManager.caseVersion: 1.1.0
spec.aiManager.channel: v3.2
spec.aiManager.size: small
spec.eventManagerGateway.enabled: false ## set to true if you want to install EvetMangerGateway
spec.eventManagerGateway.version: 1.6.3.2
spec.eventManagerGateway.caseName: ibm-netcool-prod
spec.eventManagerGateway.clusterDomain: apps.clustername.*.*.com
spec.eventManagerGateway.channel: v1.5
spec.eventManagerGateway.deploymentType: trial
```

### Option 2: Using a terminal

#### 1. Grant Argo CD Enough Permissions

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

#### 2. Login to the Argo CD server

   ```sh
   # OCP 4.8+
   argo_route=openshift-gitops-server
   argo_secret=openshift-gitops-cluster
   sa_account=openshift-gitops-argocd-application-controller

   argo_pwd=$(oc get secret ${argo_secret} \
               -n openshift-gitops \
               -o jsonpath='{.data.admin\.password}' | base64 -d ; echo ) \
   && argo_url=$(oc get route ${argo_route} \
                  -n openshift-gitops \
                  -o jsonpath='{.spec.host}') \
   && argocd login "${argo_url}" \
         --username admin \
         --password "${argo_pwd}" \
         --insecure
   ```

#### 3. Storage Consideration

It depends where the OCP comes from , if you're using fyre , then could create gitops application

  ```sh
  argocd app create ceph \
        --sync-policy automatic \
        --project default \
        --repo https://github.com/cloud-pak-gitops/cp4waiops-gitops.git \
        --path ceph \
        --revision HEAD \
        --dest-namespace rook-ceph \
        --dest-server https://kubernetes.default.svc \
        --directory-recurse
  ```

#### 4. Create a ArgoCD application to mirror image to host local registry

  ```sh
  argocd app create cp4waiops \
        --sync-policy automatic \
        --project default \
        --repo https://github.com/cloud-pak-gitops/cp4waiops-gitops.git \
        --path config/3.2/airgap/imageMirror \
        --revision HEAD \
        --dest-namespace image \
        --dest-server https://kubernetes.default.svc \
        --helm-set spec.imageMirror_namespace=image \
        --helm-set spec.localDockerRegistryHost=<localDockerRegistryHost> \
        --helm-set spec.localDockerRegistryPort=<localDockerRegistryPort> \
        --helm-set spec.localDockerRegistryUser=<localDockerRegistryUser> \
        --helm-set spec.localDockerRegistryPassword=<localDockerRegistryPassword> \
        --helm-set spec.cpRegistryPassword=<entitlement-key> \
        --helm-set spec.aiManager.enabled=false \
        --helm-set spec.aiManager.caseName=ibm-cp-waiops \
        --helm-set spec.aiManager.caseVersion=1.1.0 \
        --helm-set spec.aiManager.redhatRegistryUser=<redhatRegistryUser> \
        --helm-set spec.aiManager.redhatRegistryPassword=<redhatRegistryPassword> \
        --helm-set spec.eventManagerGateway.enabled=false \
        --helm-set spec.eventManagerGateway.caseName=ibm-netcool-prod
  ```

Where:

- <entitlement-key> is the entitlement key that you copied in [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary)


Connect your host to your air-gapped environment and connet your OCP to the gitops.

#### 5. Create a ArgoCD application for installing cp4waiops

  ```sh
  argocd app create cp4waiops \
        --sync-policy automatic \
        --project default \
        --repo https://github.com/cloud-pak-gitops/cp4waiops-gitops.git \
        --path config/3.2/cp4waiops \
        --revision HEAD \
        --dest-namespace cp4waiops \
        --dest-server <your airgap OCP cluster> \
        --helm-set spec.imageMirror_namespace=cp4waiops \
        --helm-set spec.localDockerRegistryHost=<localDockerRegistryHost> \
        --helm-set spec.localDockerRegistryPort=<localDockerRegistryPort> \
        --helm-set spec.localDockerRegistryUser=<localDockerRegistryUser> \
        --helm-set spec.localDockerRegistryPassword=<localDockerRegistryPassword> \
        --helm-set spec.storageClass=rook-cephfs \
        --helm-set spec.storageClassLargeBlock=rook-cephfs \
        --helm-set spec.aiManager.enabled=false \
        --helm-set spec.aiManager.caseName=ibm-cp-waiops \
        --helm-set spec.aiManager.caseVersion=1.1.0 \
        --helm-set spec.aiManager.channel=<redhatRegistryUser> \
        --helm-set spec.aiManager.size=<redhatRegistryPassword> \
        --helm-set spec.eventManagerGateway.enabled=false \
        --helm-set spec.eventManagerGateway.caseName=ibm-netcool-prod \
        --helm-set spec.eventManagerGateway.version=1.6.3.2 \
        --helm-set spec.eventManagerGateway.clusterDomain=apps.clustername.*.*.com \
        --helm-set spec.eventManagerGateway.channel=v1.5 \
        --helm-set spec.eventManagerGateway.deploymentType=trial
  ```

### Verify Cloud Paks Installation

#### CLI Verify

After instana instance was deployed, you can run the command as follows to check:

```
kubectl get application -A
```

In this tutorial, the output of the above command is as follows:

```console
# kubectl get application -A
NAMESPACE          NAME           SYNC STATUS   HEALTH STATUS
openshift-gitops   ceph           Synced        Healthy
openshift-gitops   cp4waiops      Synced        Healthy
openshift-gitops   mirror-image   Synced        Healthy
```

Wait a while and check if all pods under namespace `cp4waiops` and are running well without any crash.

```
kubectl get pod -n cp4waiops
```

#### UI Verify

From Argo CD UI, you will be able to see there are two applications as follows:

![cp4waiops apps](images/ocp-cp4waiops-32.png)

- The following picture is the detail of the `cp4waiops`, you can see all of the resources for this app.
![cp4waiops](images/ocp-cp4waiops-32-1.png)
![cp4waiops](images/ocp-cp4waiops-32-2.png)
![cp4waiops](images/ocp-cp4waiops-32-3.png)
![cp4waiops](images/ocp-cp4waiops-32-4.png)

### Access CP4WAIOps UI

After you successfully install IBM Cloud Pak for Watson AIOps, check [CP4WAIOPS-KC](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.2.0?topic=installation-installing-online-offline#console) to get the URL for accessing the IBM Cloud Pak for Watson AIOps console, username and password.

![w](images/waiops-login.png)

After click `Log In`, you will be navigated to the CP4WAIOps UI as follows.

![w](images/waiops-dashbord.png)
