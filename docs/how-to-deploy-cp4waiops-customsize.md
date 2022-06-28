<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Customize CP4WAIOps Sizing using GitOps](#customize-cp4waiops-sizing-using-gitops)
  - [Prerequisite](#prerequisite)
    - [Obtain an entitlement key](#obtain-an-entitlement-key)
    - [Update the OCP global pull secret](#update-the-ocp-global-pull-secret)
  - [Install CP4WAIOps with Custom Size from UI](#install-cp4waiops-with-custom-size-from-ui)
    - [Login to Argo CD](#login-to-argo-cd)
    - [Grant Argo CD Cluster Admin Permission](#grant-argo-cd-cluster-admin-permission)
    - [Install CP4WAIOps with Custom Size Using All-in-One Configuration](#install-cp4waiops-with-custom-size-using-all-in-one-configuration)
    - [Verify CP4WAIOps Installation](#verify-cp4waiops-installation)
    - [Access CP4WAIOps](#access-cp4waiops)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Customize CP4WAIOps Sizing using GitOps

## Prerequisite
For Prerequisite, please refer to [Prerequisite](https://github.com/IBM/cp4waiops-gitops/blob/docs/docs/how-to-deploy-cp4waiops.md#prerequisite)

### Obtain an entitlement key
To Obtain an entitlement key, please refer to [Obtain an entitlement key](https://github.com/IBM/cp4waiops-gitops/blob/docs/docs/how-to-deploy-cp4waiops.md#obtain-an-entitlement-key)

### Update the OCP global pull secret
To Update the OCP global pull secret, please refer to [Update the OCP global pull secret](https://github.com/IBM/cp4waiops-gitops/blob/docs/docs/how-to-deploy-cp4waiops.md#update-the-ocp-global-pull-secret)


## Install CP4WAIOps with Custom Size from UI

### Login to Argo CD

To Login to Argo CD,  please refer to [Login to Argo CD](https://github.com/IBM/cp4waiops-gitops/blob/docs/docs/how-to-deploy-cp4waiops.md#login-to-argo-cd)

### Grant Argo CD Cluster Admin Permission

To Grant Argo CD Cluster Admin Permission,  please refer to [Grant Argo CD Cluster Admin Permission](https://github.com/IBM/cp4waiops-gitops/blob/docs/docs/how-to-deploy-cp4waiops.md#grant-argo-cd-cluster-admin-permission)


### Install CP4WAIOps with Custom Size Using All-in-One Configuration

The all-in-one configuration allows you to install following components in one go:

- Ceph storage (optional)
- AI Manager
- Event Manager

For AI Manager, you can specify the installation profile with the values that are officially supported for production use:

- large
- small
- extra small: sub-profile requesting much less cpu and memory, only for demo, PoC, or dev environment in a resource (cpu and memory) limited cluster.
  - x-small
  - x-small-idle
  - x-small-custom
  
 
Just fill in the form using the suggested field values listed in following table when you create the Argo CD App:

| Field                 | Value                                                 |
| --------------------- | ----------------------------------------------------- |
| Application Name      | anyname (e.g. cp4waiops-app)                          |
| Project               | default                                               |
| Sync Policy           | Automatic                                             |
| Repository URL        | https://github.com/IBM/cp4waiops-gitops               |
| Revision              | release-3.4                                           |
| Path                  | config/all-in-one                                     |
| Cluster URL           | https://kubernetes.default.svc                        |
| Namespace             | openshift-gitops                                      |

In Helm PARAMETERS, you can also update the following install parameters that are commonly used to customize the install behavior.

| Parameter                             | Type   | Default Value      | Description 
| ------------------------------------- |--------|--------------------|-------------
| argocd.cluster                        | string | openshift          | The type of the cluster that Argo CD runs on, valid values include: openshift, kubernetes.
| argocd.allowLocalDeploy               | bool   | true               | Allow apps to be deployed on the same cluster where Argo CD runs.
| rookceph.enabled                      | bool   | true               | Specify whether or not to install Ceph as storage used by CP4WAIOps.
| cp4waiops.version                     | string | v3.4               | Specify the version of CP4WAIOps, e.g.: v3.2, v3.3, v3.4.
| **cp4waiops.profile**                 | string | small              | The CP4WAIOps deployment profile, e.g.: large, small and x-small, x-small-idle, x-small-custom for custom sizing.
| cp4waiops.aiManager.enabled           | bool   | true               | Specify whether or not to install AI Manager.
| cp4waiops.aiManager.namespace         | string | cp4waiops          | The namespace where AI Manager is installed.
| cp4waiops.aiManager.instanceName      | string | aiops-installation | The instance name of AI Manager.
| **cp4waiops.eventManager.enabled**    | bool   | true               | Specify whether or not to install Event Manager.
| cp4waiops.eventManager.namespace      | string | noi                | The namespace where Event Manager is installed.
| cp4waiops.eventManager.clusterDomain  | string | REPLACE_IT         | The domain name of the cluster where Event Manager is installed.

NOTE:

- For `cp4waiops.profile`, the profile `x-small, x-small-idle, x-small-custom` are only for demo, PoC, or dev environment in a resource (cpu and memory) limited cluster. If you are looking for official installation, use profile such as `small` or `large` instead.
- For `cp4waiops.eventManager.enabled`, it needs to be false if you use `x-small, x-small-idle, x-small-custom` profile as it only covers AI Manager, not including Event Manager.
- For `cp4waiops.eventManager.clusterDomain`, it is the domain name of the cluster where Event Manager is installed. Use fully qualified domain name (FQDN), e.g.: apps.clustername.abc.xyz.com.

To install custom sizing CP4WAIOps using **Custom Build**, please refer [Install CP4WAIOps using Custom Build](https://github.com/IBM/cp4waiops-gitops/blob/docs/docs/how-to-deploy-cp4waiops.md#install-cp4waiops-using-custom-build)

### Verify CP4WAIOps Installation

After both Ceph and CP4WAIOps are ready, you will be able to see those Apps from Argo CD UI as follows with status as `Healthy` and `Synced`.

![w](images/gitops-x-small-idle.png)

![w](images/gitops-x-small-idle-allin1.png)

You can check the topology of CP4WAIOps using Argo CD UI as follows:

![w](images/aimanager-33.png)

### Access CP4WAIOps

To access CP4WAIOps, please refer to [Access CP4WAIOps](https://github.com/IBM/cp4waiops-gitops/blob/docs/docs/how-to-deploy-cp4waiops.md#access-cp4waiops)

