<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents** *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Deploy Cloud Pak for Watson AIOps 3.6 using GitOps](#deploy-cloud-pak-for-watson-aiops-36-using-gitops)
  - [Prerequisites](#prerequisites)
  - [Installing Cloud Pak for Watson AIOps with the Argo CD UI](#installing-cloud-pak-for-watson-aiops-with-the-argo-cd-ui)
    - [Log in to Argo CD](#log-in-to-argo-cd)
    - [Grant Argo CD cluster admin permission](#grant-argo-cd-cluster-admin-permission)
    - [Configure Argo CD](#configure-argo-cd)
    - [Storage considerations](#storage-considerations)
    - [Obtain an entitlement key](#obtain-an-entitlement-key)
    - [Update the OpenShift Container Platform global pull secret](#update-the-openshift-container-platform-global-pull-secret)
    - [Option 1: Installing AI Manager and Event Manager separately](#option-1-installing-ai-manager-and-event-manager-separately)
      - [Install shared components](#install-shared-components)
      - [Install AI Manager](#install-ai-manager)
      - [Install Event Manager](#install-event-manager)
    - [Option 2: (**Technology preview**) Installing AI Manager and Event Manager with an all-in-one configuration](#option-2-technology-preview-installing-ai-manager-and-event-manager-with-an-all-in-one-configuration)
      - [Installing AI Manager and Event Manager together](#installing-ai-manager-and-event-manager-together)
      - [Installing Cloud Pak for Watson AIOps using a custom build](#installing-cloud-pak-for-watson-aiops-using-a-custom-build)
    - [Verify the Cloud Pak for Watson AIOps installation](#verify-the-cloud-pak-for-watson-aiops-installation)
    - [Access Cloud Pak for Watson AIOps](#access-cloud-pak-for-watson-aiops)
  - [Install Cloud Pak for Watson AIOps from the command line](#install-cloud-pak-for-watson-aiops-from-the-command-line)
    - [Log in to Argo CD (CLI)](#log-in-to-argo-cd-cli)
    - [Storage considerations (CLI)](#storage-considerations-cli)
    - [Option 1: Install AI Manager and Event Manager Separately (CLI)](#option-1-install-ai-manager-and-event-manager-separately-cli)
      - [Grant Argo CD cluster admin permission (CLI)](#grant-argo-cd-cluster-admin-permission-cli)
      - [Install shared components (CLI)](#install-shared-components-cli)
      - [Install AI Manager (CLI)](#install-ai-manager-cli)
      - [Install Event Manager (CLI)](#install-event-manager-cli)
    - [Option 2: (**Technology preview**) Installing AI Manager and Event Manager with an all-in-one configuration (CLI)](#option-2-technology-preview-installing-ai-manager-and-event-manager-with-an-all-in-one-configuration-cli)
    - [Verify Cloud Pak for Watson AIOps installation (CLI)](#verify-cloud-pak-for-watson-aiops-installation-cli)
  - [Troubleshooting](#troubleshooting)
    - [Storage](#storage)
      - [Problem](#problem)
      - [Cause](#cause)
      - [Solution](#solution)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Deploy Cloud Pak for Watson AIOps 3.6 using GitOps

**Using GitOps to install Cloud Pak for Watson AIOps 3.6 is a GA feature!**

The use of GitOps enables IBM Cloud Pak for Watson AIOps to be deployed on a Red Hat OpenShift Container Platform cluster from a Git repository, with the ArgoCD tool.

For more information about GitOps, see [Understanding OpenShift GitOps](https://docs.openshift.com/container-platform/4.10/cicd/gitops/understanding-openshift-gitops.html#understanding-openshift-gitops) in the Red Hat OpenShift documentation.

For more information about Argo, see the [Argo documentation](https://argo-cd.readthedocs.io/en/stable/).

Cloud Pak for Watson AIOps can be installed with the Argo CD user interface (UI), or with the Argo CD command line (CLI). You can choose from two deployment options:

Option 1: Install AI Manager and Event Manager separately

Option 2: Install AI Manager and Event Manager with an all-in-one configuration (**Technology preview**)

## Prerequisites

- Ensure that you meet the supported platform, hardware, and storage requirements. For more information, see [System requirements](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.6.0?topic=planning-system-requirements).
- You must have Red Hat OpenShift GitOps (Argo CD) installed on your Red Hat OpenShift cluster. For more information, see [Installing OpenShift GitOps](https://docs.openshift.com/container-platform/4.10/cicd/gitops/installing-openshift-gitops.html) in the Red Hat OpenShift documentation.

## Installing Cloud Pak for Watson AIOps with the Argo CD UI

### Log in to Argo CD

From your Red Hat OpenShift console, click the menu on the upper right, and select `Cluster Argo CD`.

![w](images/gitops-menu.png)

The Argo CD UI is displayed. Click `LOG IN VIA OPENSHIFT`.

![w](images/gitops-login.png)

### Grant Argo CD cluster admin permission

From the Red Hat OpenShift console, go to `User Management` > `RoleBindings` > `Create binding`. Use the form view to configure the properties for the `ClusterRoleBinding` with the following values and then click `Create`.

- Binding type  
    - Cluster-wide role binding (ClusterRoleBinding)  
- RoleBinding  
    - Name: argocd-admin  
- Role  
    - Role Name: cluster-admin  
- Subject  
    - ServiceAccount: check it  
    - Subject namespace: openshift-gitops  
    - Subject name: openshift-gitops-argocd-application-controller  

### Configure Argo CD

From the Argo CD UI, click `NEW APP`, input the following parameters, and then click `CREATE`.

- GENERAL  
    - Application Name: argocd  
    - Project: default  
    - SYNC POLICY: Automatic  
- SOURCE  
    - Repository URL : https://github.com/IBM/cp4waiops-gitops  
    - Revision: release-3.6  
    - path: config/argocd/openshift  
- DESTINATION   
    - Cluster URL: https://kubernetes.default.svc  
    - Namespace: openshift-gitops  
  
After the Argo CD App `argocd` is created, select the App from the Argo CD UI to view the topology of all of the resources.

### Storage considerations

If your Red Hat OpenShift cluster already has a default supported storage class, then skip this step.

This tutorial uses Ceph storage for demonstration purpose. You must use a supported storage. For more information about supported storage, see [Storage Considerations](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.6.0?topic=requirements-storage-considerations).

If you are deploying on AWS, then EFS (Amazon Elastic File System) can be used for persistent storage. For more information, see [Getting started with Amazon Elastic File System](https://docs.aws.amazon.com/efs/latest/ug/getting-started.html) in the AWS documentation. You can also refer to the [AWS EFS storage configuration example](aws-efs-config-example.md)

From the Argo CD UI, click `NEW APP`, input the following parameters for Ceph, and then click `CREATE`.

- GENERAL
    - Application Name: ceph
    - Project: default
    - SYNC POLICY: Automatic
- SOURCE
    - Repository URL : https://github.com/IBM/cp4waiops-gitops
    - Revision: release-3.6
    - path: config/ceph
- DESTINATION
    - Cluster URL: https://kubernetes.default.svc
    - Namespace: rook-ceph

![w](images/ceph-gitops.png)

After the Argo CD App `ceph` is created, you can click the App from the Argo CD UI to view the topology of the Ceph resources as follows:

![w](images/ceph-topo.png)

The filters on the left can be used to filter out resources. Click a resource to check its logs and events.

![w](images/res-logs.png)

Run the following command from the command line to check that none of the pods have an error status.

```console
[root@xyz.test.cp.fyre.ibm.com ~]# kubectl get po -n rook-ceph
NAME                                                              READY   STATUS      RESTARTS   AGE
csi-cephfsplugin-7b6jk                                            3/3     Running     0          2d
csi-cephfsplugin-l7mvz                                            3/3     Running     0          2d
csi-cephfsplugin-provisioner-695b574445-gfcwz                     6/6     Running     6          2d
csi-cephfsplugin-provisioner-695b574445-lb64p                     6/6     Running     7          2d
csi-cephfsplugin-qcsqz                                            3/3     Running     0          2d
csi-cephfsplugin-qdrtl                                            3/3     Running     0          2d
csi-cephfsplugin-wj7qq                                            3/3     Running     0          2d
csi-cephfsplugin-xlsnb                                            3/3     Running     0          2d
csi-rbdplugin-8xwdb                                               3/3     Running     0          2d
csi-rbdplugin-b6t9l                                               3/3     Running     0          2d
csi-rbdplugin-h965f                                               3/3     Running     0          2d
csi-rbdplugin-lv2hp                                               3/3     Running     0          2d
csi-rbdplugin-pqvrc                                               3/3     Running     0          2d
csi-rbdplugin-provisioner-7f9847cd48-48gqk                        6/6     Running     0          2d
csi-rbdplugin-provisioner-7f9847cd48-wxh2z                        6/6     Running     12         2d
csi-rbdplugin-x8cw9                                               3/3     Running     0          2d
rook-ceph-crashcollector-worker0.body.cp.fyre.ibm.com-88f5bnbdc   1/1     Running     0          2d
rook-ceph-crashcollector-worker1.body.cp.fyre.ibm.com-d4c7gdcts   1/1     Running     0          2d
rook-ceph-crashcollector-worker2.body.cp.fyre.ibm.com-7767p8fxm   1/1     Running     0          2d
rook-ceph-crashcollector-worker3.body.cp.fyre.ibm.com-6c5cqs4lk   1/1     Running     0          2d
rook-ceph-crashcollector-worker4.body.cp.fyre.ibm.com-787f99czf   1/1     Running     0          2d
rook-ceph-crashcollector-worker5.body.cp.fyre.ibm.com-94d4b654q   1/1     Running     0          2d
rook-ceph-mds-myfs-a-7d48d48497-sbhld                             1/1     Running     0          2d
rook-ceph-mds-myfs-b-66f4b746c7-2fnl2                             1/1     Running     0          2d
rook-ceph-mgr-a-5c84cd7b7b-574lf                                  1/1     Running     0          2d
rook-ceph-mon-a-7b947ddf45-74p49                                  1/1     Running     0          2d
rook-ceph-mon-b-7cf885c589-5j6r9                                  1/1     Running     0          2d
rook-ceph-mon-c-bcb6575d8-g9l5w                                   1/1     Running     0          2d
rook-ceph-operator-54649856c4-cdx24                               1/1     Running     0          2d
rook-ceph-osd-0-c44985597-gwkqk                                   1/1     Running     0          2d
rook-ceph-osd-1-6f7d5cc955-v4862                                  1/1     Running     0          2d
rook-ceph-osd-2-58df99c46f-5kl8z                                  1/1     Running     0          2d
rook-ceph-osd-3-5c8579456c-bpcqz                                  1/1     Running     0          2d
rook-ceph-osd-4-5668c69fbf-kvdf6                                  1/1     Running     0          2d
rook-ceph-osd-5-cbbdb95-cqvjd                                     1/1     Running     0          2d
rook-ceph-osd-prepare-worker0.body.cp.fyre.ibm.com-bxr7t          0/1     Completed   0          4h16m
rook-ceph-osd-prepare-worker1.body.cp.fyre.ibm.com-fftd8          0/1     Completed   0          4h16m
rook-ceph-osd-prepare-worker2.body.cp.fyre.ibm.com-scg84          0/1     Completed   0          4h16m
rook-ceph-osd-prepare-worker3.body.cp.fyre.ibm.com-m488b          0/1     Completed   0          4h16m
rook-ceph-osd-prepare-worker4.body.cp.fyre.ibm.com-dxcm5          0/1     Completed   0          4h16m
rook-ceph-osd-prepare-worker5.body.cp.fyre.ibm.com-jclnq          0/1     Completed   0          4h16m
```

If any of the pods are in an error state, you can check the logs by using `kubectl logs`.

NOTE: Multiple default storage classes cause deployment problems. Run the following command to check your cluster's storage class.

```bash
oc get sc
```

If your cluster has multiple default storage classes, then you must edit your storage classes to leave only one storage class as the default. To remove the default setting from a storage class, run the following command to edit the storage class, and then delete the `storageclass.kubernetes.io/is-default-class: "true"` line under `annotations`.

```
oc edit sc [STORAGE-CLASS-NAME]
```

### Obtain an entitlement key

Obtain your IBM Entitled Registry key to enable your deployment to pull images from the IBM Entitled Registry.

1. Obtain the entitlement key that is assigned to your IBMid. Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password details that are associated with the entitled software.

2. In the "Entitlement key" section, select "Copy key" to copy the entitlement key to the clipboard.

3. Copy the entitlement key to a safe place so that you can use it later when you update the global pull secret for the cluster.

4. (Optional) Verify the validity of the key by logging in to the IBM Entitled Registry.

   Depending on the container system that you are using, you might need to use `docker login` instead of `podman login` for the following command.

   ```sh
   export IBM_ENTITLEMENT_KEY=the key from the previous steps
   podman login cp.icr.io --username cp --password "${IBM_ENTITLEMENT_KEY:?}"
   ```

### Update the OpenShift Container Platform global pull secret

1. From the Red Hat OpenShift console, select the "Administrator" perspective, and then "Workloads > Secrets".

2. Select the project "openshift-config".
 
3. Select the object "pull-secret".

4. Click "Actions > Edit secret".

5. Scroll to the end of the page and click "Add credentials". Use the following values:

     - "Registry Server Address" cp.icr.io
     - "Username": cp
     - "Password": paste the entitlement key that you copied from the [Obtain an entitlement key](#obtain-an-entitlement-key) step
     - "Email": email address. This field is mostly a hint to other people who might see the entry in the configuration.

   NOTE: The registry user for this secret is "cp", not the name or email of the user who owns the entitlement key.

6. Click "Save".

For more information, see [Update the OpenShift Container Platform global pull secret](https://docs.openshift.com/container-platform/4.10/openshift_images/managing_images/using-image-pull-secrets.html) in the Red Hat OpenShift documentation.

### Option 1: Installing AI Manager and Event Manager separately

#### Install shared components

- GENERAL
    - Application Name: anyname (for example: "cp-shared")
    - Project: default
    - SYNC POLICY: Automatic
- SOURCE
    - Repository URL : https://github.com/IBM/cp4waiops-gitops
    - Revision: release-3.6
    - path: config/cp-shared/operators
- DESTINATION
    - Cluster URL: https://kubernetes.default.svc
    - Namespace: openshift-marketplace
- PARAMETERS
    - spec.imageCatalog: icr.io/cpopen/ibm-operator-catalog:latest
    - spec.catalogName: ibm-operator-catalog
    - spec.catalogNamespace: openshift-marketplace


#### Install AI Manager

Install AI Manager by using GitOps to create an Argo CD App for AI Manager. The parameters for AI Manager are as follows:

- GENERAL
    - Application Name: anyname (for example: "aimanager-app")
    - Project: default
    - SYNC POLICY: Automatic
- SOURCE
    - Repository URL : https://github.com/IBM/cp4waiops-gitops
    - Revision: release-3.6
    - path: config/cp4waiops/install-aimgr
- DESTINATION
    - Cluster URL: https://kubernetes.default.svc
    - Namespace: cp4waiops
- PARAMETERS
    - spec.storageClass: rook-cephfs
    - spec.storageClassLargeBlock: rook-cephfs
    - spec.aiManager.channel: v3.6
    - spec.aiManager.size: small
    - spec.aiManager.namespace: cp4waiops
    - spec.aiManager.pakModules.aiopsFoundation.enabled: true
    - spec.aiManager.pakModules.applicationManager.enabled: true
    - spec.aiManager.pakModules.aiManager.enabled: true
    - spec.aiManager.pakModules.connection.enabled: true

NOTE: If you use a repository that is forked from the official [Cloud Pak for Watson AIOps GitOps repository](https://github.com/IBM/cp4waiops-gitops) or a different branch, then you must update the values of the `Repository URL` and `Revision` parameters to match your repository and branch. For example, if you use `https://github.com/<myaccount>/cp4waiops-gitops` and `dev` branch, then these two parameters must be changed.

#### Install Event Manager

Install Event Manager by using GitOps to create an Argo CD App for Event Manager. The parameters for Event Manager are as follows:

- GENERAL
    - Application Name: anyname (for example: "eventmanager-app")
    - Project: default
    - SYNC POLICY: Automatic
- SOURCE
    - Repository URL : https://github.com/IBM/cp4waiops-gitops
    - Revision: release-3.6
    - path: config/cp4waiops/install-emgr
- DESTINATION
    - Cluster URL: https://kubernetes.default.svc
    - Namespace: noi 
- PARAMETERS
    - spec.imageCatalog: icr.io/cpopen/ibm-operator-catalog:latest
    - spec.storageClass: rook-cephfs
    - spec.storageClassLargeBlock: rook-cephfs
    - spec.eventManager.version: 1.6.6
    - spec.eventManager.clusterDomain: REPLACE_IT
    - spec.eventManager.channel: v1.10
    - spec.eventManager.deploymentType: trial
    - spec.eventManager.namespace: noi

NOTE:
- If you use a repository that is forked from the official [Cloud Pak for Watson AIOps GitOps repository](https://github.com/IBM/cp4waiops-gitops) or a different branch, then you must update the values of the `Repository URL` and `Revision` parameters to match your repository and branch. For example, if you use `https://github.com/<myaccount>/cp4waiops-gitops` and `dev` branch, then these two parameters must be changed.
- `spec.eventManager.clusterDomain` is the domain name of the cluster where Event Manager is installed. You must use a fully qualified domain name (FQDN). For example, `apps.clustername.abc.xyz.com`. You can retrieve the FQDN by running the following command:

  ```bash
  INGRESS_OPERATOR_NAMESPACE=openshift-ingress-operator
  appDomain=`kubectl -n ${INGRESS_OPERATOR_NAMESPACE} get ingresscontrollers default -o json | python -c "import json,sys;obj=json.load(sys.stdin);print obj['status']['domain'];"`
  echo ${appDomain}
  ```

### Option 2: (**Technology preview**) Installing AI Manager and Event Manager with an all-in-one configuration 

**NOTE:** This option is a technology preview, and must not be used for production systems.

#### Installing AI Manager and Event Manager together

The all-in-one configuration enables the installation of the following components in one go.

- Ceph storage (optional)
- AI Manager
- Event Manager

When you create the Argo CD app, complete the form with the following values.

| Field                 | Value                                                 |
| --------------------- | ----------------------------------------------------- |
| Application Name      | anyname (for example cp4waiops-app)                          |
| Project               | default                                               |
| Sync Policy           | Automatic                                             |
| Repository URL        | https://github.com/IBM/cp4waiops-gitops               |
| Revision              | release-3.6                                                  |
| Path                  | config/all-in-one                                     |
| Cluster URL           | https://kubernetes.default.svc                        |
| Namespace             | openshift-gitops                                      |

You can also update the following parameters to customize the installation.

| Parameter                             | Type   | Default Value      | Description 
| ------------------------------------- |--------|--------------------|-------------
| argocd.cluster                        | string | openshift          | The type of the cluster that Argo CD runs on, valid values include: openshift, kubernetes.
| argocd.allowLocalDeploy               | bool   | true               | Allow apps to be deployed on the same cluster where Argo CD runs.
| rookceph.enabled                      | bool   | true               | Specify whether to install Ceph as storage used by Cloud Pak for Watson AIOps.
| cp4waiops.version                     | string | v3.6               | Specify the version of Cloud Pak for Watson AIOps v3.6.
| cp4waiops.profile                     | string | small              | The Cloud Pak for Watson AIOps deployment profile: x-small, small, or large.
| cp4waiops.aiManager.enabled           | bool   | true               | Specify whether to install AI Manager.
| cp4waiops.aiManager.namespace         | string | cp4waiops          | The namespace where AI Manager is installed.
| cp4waiops.aiManager.instanceName      | string | aiops-installation | The instance name of AI Manager.
| cp4waiops.eventManager.enabled        | bool   | true               | Specify whether to install Event Manager.
| cp4waiops.eventManager.namespace      | string | noi                | The namespace where Event Manager is installed.
| cp4waiops.eventManager.clusterDomain  | string | REPLACE_IT         | The domain name of the cluster where Event Manager is installed.

NOTE:

- `cp4waiops.profile` The profile `x-small` is only suitable for demonstrations and proof-of-concept deployments. Production environments must use a `small` or `large` profile.
- `cp4waiops.eventManager.enabled` This must be false if you have a value of `x-small` for `cp4waiops.profile`, as this profile size is only suitable for deployments of AI Manager, and not for deployments of AI Manager and Event Manager.
- `cp4waiops.eventManager.clusterDomain` This is the domain name of the cluster where Event Manager is installed. Use a fully qualified domain name (FQDN). For example, `apps.clustername.abc.xyz.com`.

#### Installing Cloud Pak for Watson AIOps using a custom build

The all-in-one configuration enables a custom build of Cloud Pak for Watson AIOps to be installed by providing a specific image catalog and channel.

Use the installation parameters listed in following table when you create the Argo CD App.

| Parameter                           | Type   | Default Value                             | Description 
| ----------------------------------- |--------|-------------------------------------------|-----------------------------------
| cp4waiops.aiManager.imageCatalog    | string | icr.io/cpopen/ibm-operator-catalog:latest | The image catalog for AI Manager.
| cp4waiops.aiManager.channel         | string | v3.6                                      | The subscription channel for AI Manager.
| cp4waiops.eventManager.imageCatalog | string | icr.io/cpopen/ibm-operator-catalog:latest | The image catalog for Event Manager.
| cp4waiops.eventManager.channel      | string | v1.10                                     | The subscription channel for Event Manager.

These parameters are invisible when you create the Argo CD App from the UI, but you can add them in the `HELM` > `VALUES` field when you are completing the form.

For example, adding the following YAML snippet to the `HELM` > `VALUES` field installs AI Manager and Event Manager with a custom `imageCatalog` and `channel`:

```yaml
cp4waiops:
  aiManager:
    imageCatalog: <my_custom_image_catalog_for_ai_manager>
    channel: <my_custom_channel_for_ai_manager>
  eventManager:
    imageCatalog: <my_custom_image_catalog_for_event_manager>
    channel: <my_custom_channel_for_event_manager>
```

The all-in-one configuration also exposes some more installation parameters that are not visible from the UI that enable further customization of the installation. The following table lists some of these parameters. To find out more about the usage of these parameters, see [Cloud Pak for Watson AIOps Customized Install Options Using GitOps](./cp4waiops-custom-install.md).

| Parameter                             | Type   | Default Value | Description 
| ------------------------------------- |--------|---------------|-----------------------------------
| cp4waiops.storageClass                | string | rook-cephfs   | The storage class for Cloud Pak for Watson AIOps to use.
| cp4waiops.storageClassLargeBlock      | string | rook-cephfs   | The storage class for large block for Cloud Pak for Watson AIOps to use.
| cp4waiops.eventManager.version        | string | 1.6.6         | The version of Event Manager.
| cp4waiops.eventManager.deploymentType | string | trial         | The deployment type of Event Manager, valid values include: trial, production.
| globalImagePullSecrets                | array  | n/a           | A list of registry secrets that are needed for pulling images during the installation.

For example, if the custom build to be installed includes images from registries other than the official IBM Entitled Registry, you can use `globalImagePullSecrets` to specify all the necessary information to access these registries, such as registry URL, username, and password.

These parameters are invisible when you create the Argo CD App from the UI, but you can add them in the `HELM` > `VALUES` field when you are completing the form. For example,

```yaml
globalImagePullSecrets:
- registry: <my_own_registry_1>
  username: <username_to_registry_1>
  password: <password_to_registry_1>
- registry: <my_own_registry_2>
  username: <username_to_registry_2>
  password: <password_to_registry_2>
```

### Verify the Cloud Pak for Watson AIOps installation

When Ceph and Cloud Pak for Watson AIOps are ready, you can see these Apps with a status of `Healthy` and `Synced` in the Argo CD UI.

![w](images/all-in-one-apps.png)

![w](images/application-sets.png)

You can check the topology of Cloud Pak for Watson AIOps from the Argo CD UI as follows:

![w](images/aimanager-33.png)

![w](images/eventmanager-33.png)

You can also check your Cloud Pak for Watson AIOps installation from the command line. For example, to check the AI Manager pods, run the following command:

```console
[root@api.body.cp.fyre.ibm.com ~]# kubectl get po -n cp4waiops
NAME                                                              READY   STATUS      RESTARTS   AGE
aimanager-aio-ai-platform-api-server-7c877989d6-7jh55             1/1     Running     0          47h
aimanager-aio-change-risk-654884bd8c-6xpxw                        1/1     Running     0          47h
aimanager-aio-chatops-orchestrator-7c54fc5664-rtmrp               1/1     Running     0          47h
aimanager-aio-chatops-slack-integrator-77fc9499c4-wtclt           1/1     Running     0          47h
aimanager-aio-chatops-teams-integrator-577f6b85bf-j2995           1/1     Running     0          47h
aimanager-aio-controller-86875d4b7-jfwwp                          1/1     Running     0          47h
aimanager-aio-create-secrets-ccjdg                                0/1     Completed   0          47h
aimanager-aio-create-truststore-5hxps                             0/1     Completed   0          47h
aimanager-aio-curator-job-27362220-k59t8                          0/1     Completed   0          142m
aimanager-aio-curator-job-27362280-n2w88                          0/1     Completed   0          82m
aimanager-aio-curator-job-27362340-qkwln                          0/1     Completed   0          22m
aimanager-aio-log-anomaly-detector-fdfcbb96b-rpb9q                1/1     Running     0          47h
aimanager-aio-log-anomaly-detector-fdfcbb96b-v426m                1/1     Running     0          47h
aimanager-aio-similar-incidents-service-77cc9d699f-qlxgg          1/1     Running     0          47h
aimanager-ibm-minio-0                                             1/1     Running     0          47h
aimanager-operator-585d799f9f-w22vz                               1/1     Running     0          47h
aiops-ai-model-ui-674b4f77f9-qv56n                                1/1     Running     0          47h
aiops-akora-ui-7bc6d5dd6b-6n9rs                                   1/1     Running     0          47h
aiops-application-details-ui-66779f957b-fqfhk                     1/1     Running     0          47h
aiops-base-ui-5b9f885888-pvm7z                                    1/1     Running     0          47h
aiops-connections-ui-7996699c55-m79fl                             1/1     Running     0          47h
aiops-ir-analytics-classifier-75869fd78b-p2s9v                    1/1     Running     0          47h
aiops-ir-analytics-probablecause-6dd5ffd867-rrg6b                 1/1     Running     2          47h
aiops-ir-analytics-spark-master-5cd57946d4-99bqt                  1/1     Running     0          47h
aiops-ir-analytics-spark-pipeline-composer-795f965b6d-vkjqw       1/1     Running     0          47h
aiops-ir-analytics-spark-worker-65d57f7f9c-4nsb8                  1/1     Running     0          47h
aiops-ir-core-archiving-754dcb5fcb-jm82z                          1/1     Running     0          47h
aiops-ir-core-archiving-setup-rrlkh                               0/1     Completed   0          47h
aiops-ir-core-cem-users-65b9b699b9-hzh9b                          1/1     Running     0          47h
aiops-ir-core-esarchiving-67dbb7c5d7-wg7dx                        1/1     Running     0          47h
aiops-ir-core-logstash-6c89d66f79-tlfcl                           1/1     Running     0          47h
aiops-ir-core-ncobackup-0                                         2/2     Running     0          47h
aiops-ir-core-ncodl-api-59f977b475-lx7n4                          1/1     Running     0          47h
aiops-ir-core-ncodl-if-66cf44c565-lkkgx                           1/1     Running     0          47h
aiops-ir-core-ncodl-ir-7469fd4866-wjfvf                           1/1     Running     0          47h
aiops-ir-core-ncodl-jobmgr-76d74b5567-t77wc                       1/1     Running     0          47h
aiops-ir-core-ncodl-setup-8hx6c                                   0/1     Completed   0          47h
aiops-ir-core-ncodl-std-7677546c8d-dbqm9                          1/1     Running     0          47h
aiops-ir-core-ncodl-std-7677546c8d-wf82d                          1/1     Running     0          47h
aiops-ir-core-ncoprimary-0                                        1/1     Running     0          47h
aiops-ir-lifecycle-create-policies-job-dljxp                      0/1     Completed   0          47h
aiops-ir-lifecycle-eventprocessor-ep-jobmanager-0                 2/2     Running     0          47h
aiops-ir-lifecycle-eventprocessor-ep-taskmanager-0                1/1     Running     0          47h
aiops-ir-lifecycle-logstash-77579f5d7f-9rhsx                      1/1     Running     0          47h
aiops-ir-lifecycle-policy-grpc-svc-6b59698569-cvhvq               1/1     Running     0          47h
aiops-ir-lifecycle-policy-registry-svc-68647d4cdc-t27mw           1/1     Running     0          47h
aiops-ir-lifecycle-policy-registry-svc-job-8gk89                  0/1     Completed   3          47h
aiops-ir-ui-api-graphql-68488c7675-87mbp                          1/1     Running     0          47h
aiops-topology-cassandra-0                                        1/1     Running     0          47h
aiops-topology-cassandra-auth-secret-generator-7mm84              0/1     Completed   0          47h
aiops-topology-file-observer-5757769dd5-xxc8j                     1/1     Running     0          47h
aiops-topology-kubernetes-observer-d4c8bcb55-ddbcg                1/1     Running     0          47h
aiops-topology-layout-6b957b5bbb-m28rd                            1/1     Running     0          47h
aiops-topology-merge-76c494795f-5b65g                             1/1     Running     0          47h
aiops-topology-observer-service-6f5d6fb44b-jswwp                  1/1     Running     0          47h
aiops-topology-rest-observer-799bfdf4c8-5nt6n                     1/1     Running     0          47h
aiops-topology-search-6cd7cc9d8-64bdk                             1/1     Running     0          47h
aiops-topology-secret-manager-2b84s                               0/1     Completed   0          47h
aiops-topology-servicenow-observer-84c588df5b-gm6p2               1/1     Running     0          47h
aiops-topology-status-58ddcdc845-mqpzg                            1/1     Running     0          47h
aiops-topology-topology-577b988f78-kc2m6                          1/1     Running     2          47h
aiops-topology-ui-api-bbd74965d-gzlfd                             1/1     Running     0          47h
aiops-topology-vmvcenter-observer-86b6c8dc44-krvtj                1/1     Running     0          47h
aiopsedge-github-topology-integrator-7b9db59cd8-nbdgz             1/1     Running     0          47h
aiopsedge-operator-controller-manager-9b68ddd75-5rqqz             1/1     Running     1          47h
aiopsedge-operator-controller-manager-9b68ddd75-xj7tq             1/1     Running     1          47h
asm-operator-548c8894fd-r2dgv                                     1/1     Running     0          47h
c-example-couchdbcluster-m-0                                      3/3     Running     0          47h
c-example-redis-m-0                                               4/4     Running     0          47h
c-example-redis-m-1                                               4/4     Running     0          47h
c-example-redis-m-2                                               4/4     Running     0          47h
c-example-redis-s-0                                               4/4     Running     0          47h
c-example-redis-s-1                                               4/4     Running     0          47h
c-example-redis-s-2                                               4/4     Running     0          47h
camel-k-kit-c7c60rolvegv49tvh8fg-1-build                          0/1     Completed   0          47h
camel-k-kit-c7c60sglvegv49tvh8g0-1-build                          0/1     Completed   0          47h
camel-k-kit-c7c60tglvegv49tvh8gg-1-build                          0/1     Completed   0          47h
camel-k-kit-c7c60tolvegv49tvh8h0-1-build                          0/1     Completed   0          47h
camel-k-operator-684f46fc4d-s6hf2                                 1/1     Running     0          47h
configure-aiops-network-policy-967ll                              0/1     Completed   0          47h
connector-controller-bc7fc6668-f8nn5                              1/1     Running     0          47h
connector-synchronizer-7d4546ddd4-5kbrl                           1/1     Running     0          47h
couchdb-operator-d5cb7ff8c-rjnhx                                  1/1     Running     0          47h
cp4waiops-eventprocessor-eve-29ee-ep-jobmanager-0                 2/2     Running     0          47h
cp4waiops-eventprocessor-eve-29ee-ep-jobmanager-1                 2/2     Running     0          47h
cp4waiops-eventprocessor-eve-29ee-ep-taskmanager-0                1/1     Running     1          47h
cp4waiops-eventprocessor-eve-29ee-ep-taskmanager-1                1/1     Running     0          47h
cp4waiops-image-pull-secret-6fprf                                 0/1     Completed   0          2d
cp4waiops-patch-j4qrm                                             0/1     Completed   0          2d
cp4waiops-postgres-keeper-0                                       1/1     Running     0          47h
cp4waiops-postgres-postgresql-create-cluster-7xb6t                0/1     Completed   0          47h
cp4waiops-postgres-proxy-648bc64fd-x4mvv                          1/1     Running     0          47h
cp4waiops-postgres-sentinel-5878f67f46-gvv7l                      1/1     Running     0          47h
cp4waiops-postgresdb-postgresql-create-database-9j6kq             0/1     Completed   0          47h
create-secrets-job-nx6dg                                          0/1     Completed   0          47h
gateway-kong-5d45b77fb4-tgjcv                                     2/2     Running     2          47h
gateway-kong-config-svc-27362360-9dmzc                            0/1     Completed   0          2m51s
iaf-core-operator-controller-manager-58dfd97f5c-bdd9t             1/1     Running     0          2d
iaf-eventprocessing-operator-controller-manager-5bc597797f6fxm4   1/1     Running     1          2d
iaf-flink-operator-controller-manager-7dc56c9b68-6rgtk            1/1     Running     0          2d
iaf-operator-controller-manager-6bc8f44ff7-rrrnx                  1/1     Running     0          2d
iaf-system-elasticsearch-es-aiops-0                               2/2     Running     0          47h
iaf-system-entity-operator-6b5444f575-7tdfw                       3/3     Running     0          47h
iaf-system-kafka-0                                                1/1     Running     0          47h
iaf-system-zookeeper-0                                            1/1     Running     0          47h
iaf-zen-tour-job-fhdfr                                            0/1     Completed   0          47h
iam-config-job-tfsst                                              0/1     Completed   0          47h
ibm-aiops-orchestrator-6c7cfc85b7-wqdnr                           1/1     Running     0          2d
ibm-cloud-databases-redis-operator-854cf65c4f-4rrvn               1/1     Running     0          47h
ibm-common-service-operator-5cd6947dc8-z8plb                      1/1     Running     0          2d
ibm-elastic-operator-controller-manager-5d6c467b55-wtrvg          1/1     Running     0          2d
ibm-ir-ai-operator-controller-manager-59b88c6bf6-ncnbt            1/1     Running     7          47h
ibm-kong-operator-6ff97bcdb9-rl7cp                                1/1     Running     0          47h
ibm-nginx-cd84b4d8-7ttn2                                          1/1     Running     0          47h
ibm-nginx-cd84b4d8-zp4t2                                          1/1     Running     0          47h
ibm-postgreservice-operator-controller-manager-8b7bdf589-hbg2g    1/1     Running     2          47h
ibm-secure-tunnel-operator-657dd7b78f-tsgws                       1/1     Running     0          47h
ibm-vault-deploy-consul-0                                         1/1     Running     0          47h
ibm-vault-deploy-vault-0                                          1/1     Running     0          47h
ibm-vault-deploy-vault-cron-job-27361440-qxpjl                    0/1     Completed   0          15h
ibm-vault-deploy-vault-injector-596567d459-wzkws                  1/1     Running     0          47h
ibm-vault-operator-controller-manager-5957bb5ff9-4zdrb            1/1     Running     0          47h
ibm-watson-aiops-ui-operator-controller-manager-b8cf6fff7-msspt   1/1     Running     0          47h
ir-core-operator-controller-manager-76dbdb699d-g97ng              1/1     Running     7          47h
ir-lifecycle-operator-controller-manager-64bdd8f7b6-pn46g         1/1     Running     9          47h
model-train-classic-operator-56d487585c-4dv5b                     1/1     Running     2          47h
modeltrain-ibm-modeltrain-lcm-865b7f85cc-jfq4z                    1/1     Running     0          47h
modeltrain-ibm-modeltrain-ratelimiter-595f4f478-r9dwp             1/1     Running     0          47h
modeltrain-ibm-modeltrain-trainer-5b7f7888b5-c8cz5                1/1     Running     0          47h
post-aiops-resources-t4ww9                                        0/1     Completed   0          47h
post-aiops-translations-t58bb                                     0/1     Completed   0          47h
post-aiops-update-user-role-kcr8k                                 0/1     Completed   0          47h
scm-handlers-d655679fc-lvls2                                      2/2     Running     0          47h
setup-nginx-job-tn8sc                                             0/1     Completed   0          47h
snow-handlers-d8488f6f8-8lhxh                                     2/2     Running     0          47h
sre-tunnel-controller-84565ff4f8-4qtwl                            1/1     Running     0          47h
sre-tunnel-tunnel-network-api-589fd6646d-7znnh                    1/1     Running     0          47h
sre-tunnel-tunnel-ui-mcmtunnelui-fff9b859b-g7dlk                  1/1     Running     0          47h
usermgmt-5fb7986c7b-dwmk2                                         1/1     Running     0          47h
usermgmt-5fb7986c7b-ssk86                                         1/1     Running     0          47h
zen-audit-678b54b548-n7q7f                                        1/1     Running     0          47h
zen-core-64c6d56db-d25zm                                          1/1     Running     0          47h
zen-core-64c6d56db-glv65                                          1/1     Running     1          47h
zen-core-api-85489478d6-95pck                                     1/1     Running     0          47h
zen-core-api-85489478d6-n9x5s                                     1/1     Running     0          47h
zen-metastoredb-0                                                 1/1     Running     0          47h
zen-metastoredb-1                                                 1/1     Running     0          47h
zen-metastoredb-2                                                 1/1     Running     0          47h
zen-metastoredb-certs-lblhv                                       0/1     Completed   0          47h
zen-metastoredb-init-hvlv2                                        0/1     Completed   0          47h
zen-post-requisite-job-lpkfw                                      0/1     Completed   0          47h
zen-pre-requisite-job-2klrt                                       0/1     Completed   0          47h
zen-watcher-d8b795b46-2q6zx                                       1/1     Running     0          47h
```

If any pods are in an error state, you can check the logs from the Argo CD UI, or you can run `kubectl logs` from the command line.

### Access Cloud Pak for Watson AIOps

If all of the pods for Cloud Pak for Watson AIOps are up and running, then you can log in to Cloud Pak for Watson AIOps UI as follows.

Log in to Red Hat OpenShift console, and then click the drop-down menu on the upper right.

![w](images/ocp-hub.png)

Click the link to `IBM Cloud Pak for Administration` and select `OpenShift authentication`.

![w](images/cpk-hub.png)

Log in to `IBM Cloud Pak for Administration`, click the drop-down menu on the upper right, and then select `IBM Automation (cp4waiops)`.

![w](images/cpk-hub-ui.png)

Log in to the Cloud Pak for Watson AIOps UI and then select `OpenShift authentication`.

![w](images/cp4waiops.png)

The Cloud Pak for Watson AIOps user interface is displayed.

![w](images/cp4waiops-ui.png)

Congratulations! You are ready to play with Cloud Pak for Watson AIOps!

## Install Cloud Pak for Watson AIOps from the command line

### Log in to Argo CD (CLI)

Make sure that the Argo CD CLI (`argocd` command) is installed. For more information, see the [Argo documentation](https://argo-cd.readthedocs.io/en/stable/cli_installation/).

Then run following commands to log in to Argo CD:

```sh
argo_route=openshift-gitops-server
argo_secret=openshift-gitops-cluster
sa_account=openshift-gitops-argocd-application-controller

argo_pwd=$(kubectl get secret ${argo_secret} \
            -n openshift-gitops \
            -o jsonpath='{.data.admin\.password}' | base64 -d ; echo ) \
&& argo_url=$(kubectl get route ${argo_route} \
               -n openshift-gitops \
               -o jsonpath='{.spec.host}') \
&& argocd login "${argo_url}" \
      --username admin \
      --password "${argo_pwd}" \
      --insecure
```

### Storage considerations (CLI)

If your Red Hat OpenShift cluster already has a default supported storage class, then skip this step.

This tutorial uses Ceph storage for demonstration purpose. You must use a supported storage. For more information about supported storage, see [Storage Considerations](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.6.0?topic=requirements-storage-considerations).

To create an Argo CD App for Ceph storage, run the following command:

```sh
argocd app create ceph \
  --sync-policy automatic \
  --project default \
  --repo https://github.com/IBM/cp4waiops-gitops.git \
  --path config/ceph \
  --revision release-3.6 \
  --dest-namespace rook-ceph \
  --dest-server https://kubernetes.default.svc
```
### Option 1: Install AI Manager and Event Manager Separately (CLI)

#### Grant Argo CD cluster admin permission (CLI)

Apply the following YAML manifest to the cluster where Argo CD runs:

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

#### Install shared components (CLI)

```sh
argocd app create cp-shared \
      --sync-policy automatic \
      --project default \
      --repo https://github.com/IBM/cp4waiops-gitops.git \
      --path config/cp-shared/operators \
      --revision release-3.6 \
      --dest-namespace openshift-marketplace \
      --dest-server https://kubernetes.default.svc \
      --helm-set spec.imageCatalog=icr.io/cpopen/ibm-operator-catalog:latest \
      --helm-set spec.catalogName=ibm-operator-catalog \
      --helm-set spec.catalogNamespace=openshift-marketplace
```

#### Install AI Manager (CLI)

Run the following command to install AI Manager by using GitOps to create an Argo CD App for AI Manager.

```sh
argocd app create aimanager-app \
      --sync-policy automatic \
      --project default \
      --repo https://github.com/IBM/cp4waiops-gitops.git \
      --path config/cp4waiops/install-aimgr \
      --revision release-3.6 \
      --dest-namespace cp4waiops \
      --dest-server https://kubernetes.default.svc \
      --helm-set spec.storageClass=rook-cephfs \
      --helm-set spec.storageClassLargeBlock=rook-cephfs \
      --helm-set spec.aiManager.namespace=cp4waiops \
      --helm-set spec.aiManager.channel=v3.6 \
      --helm-set spec.aiManager.size=small \
      --helm-set spec.aiManager.pakModules.aiopsFoundation.enabled=true \
      --helm-set spec.aiManager.pakModules.applicationManager.enabled=true \
      --helm-set spec.aiManager.pakModules.aiManager.enabled=true \
      --helm-set spec.aiManager.pakModules.connection.enabled=true
```

#### Install Event Manager (CLI)

Run the following command to install Event Manager by using GitOps to create an Argo CD App for Event Manager.

```sh
argocd app create eventmanager-app \
      --sync-policy automatic \
      --project default \
      --repo https://github.com/IBM/cp4waiops-gitops.git \
      --path config/cp4waiops/install-emgr \
      --revision release-3.6 \
      --dest-namespace noi \
      --dest-server https://kubernetes.default.svc \
      --helm-set spec.imageCatalog=icr.io/cpopen/ibm-operator-catalog:latest \
      --helm-set spec.storageClass=rook-cephfs \
      --helm-set spec.storageClassLargeBlock=rook-cephfs \
      --helm-set spec.eventManager.namespace=noi \
      --helm-set spec.eventManager.channel=v1.10 \
      --helm-set spec.eventManager.version=1.6.6 \
      --helm-set spec.eventManager.clusterDomain=REPLACE_IT \
      --helm-set spec.eventManager.deploymentType=trial
```

NOTE: 
- `cp4waiops.eventManager.clusterDomain` is the domain name of the cluster where Event Manager is installed. Use a fully qualified domain name (FQDN). For example, `apps.clustername.abc.xyz.com`. You can also retrieve the FDQN by running the following command:

  ```bash
  INGRESS_OPERATOR_NAMESPACE=openshift-ingress-operator
  appDomain=`kubectl -n ${INGRESS_OPERATOR_NAMESPACE} get ingresscontrollers default -o json | python -c "import json,sys;obj=json.load(sys.stdin);print obj['status']['domain'];"`
  echo ${appDomain}
  ```

### Option 2: (**Technology preview**) Installing AI Manager and Event Manager with an all-in-one configuration (CLI)

**NOTE:** This option is a technology preview, and must not be used for production systems.

To install Ceph, AI Manager, and Event Manager in one go with an all-in-one configuration, run the following command.

```sh
argocd app create cp4waiops-app \
      --sync-policy automatic \
      --project default \
      --repo https://github.com/IBM/cp4waiops-gitops.git \
      --path config/all-in-one \
      --revision release-3.6 \
      --dest-namespace openshift-gitops \
      --dest-server https://kubernetes.default.svc \
      --helm-set argocd.cluster=openshift \
      --helm-set argocd.allowLocalDeploy=true \
      --helm-set rookceph.enabled=true \
      --helm-set cp4waiops.version=v3.6 \
      --helm-set cp4waiops.profile=small \
      --helm-set cp4waiops.aiManager.enabled=true \
      --helm-set cp4waiops.aiManager.namespace=cp4waiops \
      --helm-set cp4waiops.aiManager.instanceName=aiops-installation \
      --helm-set cp4waiops.eventManager.enabled=true \
      --helm-set cp4waiops.eventManager.clusterDomain=REPLACE_IT \
      --helm-set cp4waiops.eventManager.namespace=noi
```
NOTE:

- `cp4waiops.profile` The profile `x-small` is only suitable for demonstrations and proof-of-concept deployments. Production environments must use a `small` or `large` profile.
- `cp4waiops.eventManager.enabled` This must be false if you have a value of `x-small` for `cp4waiops.profile`, as this profile size is only suitable for deployments of AI Manager, and not for deployments of AI Manager and Event Manager.
- `cp4waiops.eventManager.clusterDomain` This is the domain name of the cluster where Event Manager is installed. Use a fully qualified domain name (FQDN). For example, `apps.clustername.abc.xyz.com`.

### Verify Cloud Pak for Watson AIOps installation (CLI)

Run the following command to verify that the Cloud Pak for Watson AIOps installation was successful:

```sh
kubectl get application -A
```

Example output from a successful installation:

```console
# kubectl get application -A
NAMESPACE          NAME                      SYNC STATUS   HEALTH STATUS
openshift-gitops   cp4waiops                 Synced        Healthy
openshift-gitops   in-cluster-aimanager      Synced        Healthy
openshift-gitops   in-cluster-eventmanager   Synced        Healthy
openshift-gitops   in-cluster-rook-ceph      Synced        Healthy
```

Wait for a while and then run the following commands to verify that all of the pods in the `cp4waiops` and `noi` namespaces are running.

```
kubectl get pod -n cp4waiops
kubectl get pod -n noi
```

## Troubleshooting

### Storage

#### Problem

Ceph pod reports the following error:

`cephosd: failed to lookup binary path "/rootfs/usr/sbin/lvm" on the host rootfs`.

#### Cause

This problem is caused by missing lvm2 support. For more information, see [issue 6705](https://github.com/rook/rook/issues/6057#issuecomment-681732903).

#### Solution

Install lvm2 on all Red Hat OpenShift nodes.
