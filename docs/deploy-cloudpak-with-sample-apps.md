<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Deploy Cloud Pak for Watson AIOps Demo Environment in One click](#deploy-cp4waiops-demo-environment-in-one-click)
  - [About X-Small Profile](#about-x-small-profile)
  - [Prepare Environment](#prepare-environment)
  - [Install Cloud Pak for Watson AIOps Demo Environment](#install-cp4waiops-demo-environment)
  - [Access Environment](#access-environment)
    - [Cloud Pak for Watson AIOps](#cp4waiops)
    - [Robot Shop](#robot-shop)
    - [Humio](#humio)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Deploy Cloud Pak for Watson AIOps demo environment in one click

Learn how to deploy an IBM Cloud Pak for Watson AIOps demo environment using GitOps in one click.

- Deploy Cloud Pak for Watson AIOps using custom profile `x-small` in a sandbox with restricted resources.
- Set up an integration with Humio, Kafka, Kubernetes, and more as postinstallation steps automatically.
- Deploy Robot Shop as a sample application, and other dependencies on the same cluster where Cloud Pak for Watson AIOps runs.

This installation scenario is tested and verified against Cloud Pak for Watson AIOps 3.2 and 3.3.

![](images/00-demo-env.png)

## About x-small profile

The `x-small` profile is not an official profile that is supported by Cloud Pak for Watson AIOps at the momentm as it only covers AI Manager and does not include Event Manager. As an experimental feature, you can use it to set up demonstrations, proof-of-concept deployments, or development environments.

Although in this installation scenario the `x-small` profile is used, this approach also supports a Cloud Pak for Watson AIOps installation in a production environment using official profiles such as `small` or `large`.

## Prepare environment

Prepare a Red Hat Red Hat OpenShift cluster as your demonstration environment. If you use the `x-small` profile, it is recommended to set up a cluster with three worker nodes where each node has 16 cores CPU and 32 GB memory.

Before you start to install the demonstration environment, make sure that you have installed Red Hat Red Hat OpenShift GitOps (Argo CD) on the cluster. To install Red Hat OpenShift GitOps, refer to [Installing OpenShift GitOps](https://docs.openshift.com/container-platform/4.8/cicd/gitops/installing-openshift-gitops.html).

These instructions use Argo CD to install the following applications in one go:

| Application        | Required | Description
| ------------------ | -------- | -------------------------------------------------------------------
| Ceph               | No       | The storage that is used by Cloud Pak for Watson AIOps and other applications. It can be skipped if you already have storage solution available on your target cluster.
| Cloud Pak for Watson AIOps          | Yes      | IBM Cloud Pak for Watson AIOps.
| Robot Shop         | No       | The sample application used to demonstrate Cloud Pak for Watson AIOps features.
| Humio & Fluent Bit | No       | The log collector that is used by Cloud Pak for Watson AIOps for log anomaly detecting.
| Istio              | No       | The service mesh used by sample application for fault injection.

NOTE: This example uses Ceph storage for demonstration purpose. You must use a supported storage. For more information about supported storage, see [Storage Considerations](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.5.0?topic=requirements-storage-considerations).

## Install Cloud Pak for Watson AIOps Demo Environment

Log in to Argo CD, then start the installation by clicking the `NEW APP` button on upper left to create an Argo CD App.

Complete the form using the suggested field values listed in following table:

| Field                 | Value                                                 |
| --------------------- | ----------------------------------------------------- |
| Application Name      | cp4waiops-demo                                        |
| Project               | default                                               |
| Sync Policy           | Automatic                                             |
| Repository URL        | https://github.com/IBM/cp4waiops-gitops               |
| Revision              | HEAD                                                  |
| Path                  | config/all-in-one                                     |
| Cluster URL           | https://kubernetes.default.svc                        |
| Namespace             | openshift-gitops                                      |

NOTE:

NOTE: If you use a repository that is forked from the official [Cloud Pak for Watson AIOps GitOps repository](https://github.com/IBM/cp4waiops-gitops) or a different branch, then you must update the values of the `Repository URL` and `Revision` parameters to match your repository and branch. For example, if you use `https://github.com/<myaccount>/cp4waiops-gitops` and `dev` branch, then these two parameters must be changed.

You can also update the following parameters to customize the installation.

| Parameter                             | Type   | Default Value      | Description 
| ------------------------------------- |--------|--------------------|-------------
| argocd.cluster                        | string | openshift          | The type of the cluster that Argo CD runs on, valid values include: openshift, kubernetes.
| argocd.allowLocalDeploy               | bool   | true               | Allow apps to be deployed on the same cluster where Argo CD runs.
| rookceph.enabled                      | bool   | true               | Specify whether or not to install Ceph as storage used by Cloud Pak for Watson AIOps.
| cp4waiops.version                     | string | v3.3               | Specify the version of Cloud Pak for Watson AIOps, e.g.: v3.2, v3.3.
| cp4waiops.profile                     | string | small              | The Cloud Pak for Watson AIOps deployment profile, for example: x-small, small, large.
| cp4waiops.dockerUsername              | string | cp                 | The username of image registry used to pull images.
| cp4waiops.dockerPassword              | string | REPLACE_IT         | The password of image registry used to pull images.
| cp4waiops.aiManager.enabled           | bool   | true               | Specify whether to install AI Manager.
| cp4waiops.aiManager.namespace         | string | cp4waiops          | The namespace where AI Manager is installed.
| cp4waiops.aiManager.instanceName      | string | aiops-installation | The instance name of AI Manager.
| cp4waiops.eventManager.enabled        | bool   | true               | Specify whether to install Event Manager.
| cp4waiops.eventManager.namespace      | string | noi                | The namespace where Event Manager is installed.
| cp4waiops.eventManager.clusterDomain  | string | REPLACE_IT         | The domain name of the cluster where Event Manager is installed.

NOTE:

- `cp4waiops.dockerPassword` This is the entitlement key that you can copy from [My IBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary).
- `cp4waiops.profile` The profile `x-small` is only suitable for demonstrations and proof-of-concept deployments. Production environments must use a `small` or `large` profile.
- `cp4waiops.eventManager.enabled` This must be false if you have a value of `x-small` for `cp4waiops.profile`, as this profile size is only suitable for deployments of AI Manager, and not for deployments of AI Manager and Event Manager.
- `cp4waiops.eventManager.clusterDomain` This is the domain name of the cluster where Event Manager is installed. Use a fully qualified domain name (FQDN). For example, `apps.clustername.abc.xyz.com`.

The following installation parameters are not commonly used, so they are invisible when you create the Argo CD App from UI. But you can add them when completing the form in `HELM` > `VALUES` field.

| Parameter                          | Type   | Default Value  | Description 
| ---------------------------------- |--------|----------------|-------------
| cp4waiops.setup.enabled            | bool   | false          | Set up Cloud Pak for Watson AIOps after it is installed.
| cp4waiops.setup.humio.enabled      | bool   | true           | Setup Humio integration.
| cp4waiops.setup.kafka.enabled      | bool   | true           | Setup Kafka integration.
| cp4waiops.setup.kubernetes.enabled | bool   | true           | Setup Kubernetes integration. 
| robotshop.enabled                  | bool   | false          | Specify whether to install Robot Shop.
| humio.enabled                      | bool   | false          | Specify whether to install Humio. 
| istio.enabled                      | bool   | false          | Specify whether to install Istio.

For example, adding the following YAML snippet to `HELM` > `VALUES` field enables Robot Shop, Humio, and Istio: 

```yaml
robotshop:
  enabled: true
humio:
  enabled: true
istio:
  enabled: true
```

When the form is completed, click `CREATE` to start the installation. Whilst waiting for the install to complete, you will see more Apps being rolled out gradually from the Argo CD UI. Each App represents a specific application to be deployed and is managed by the root level App.

![](images/01-apps.png)

Depending on the installation parameters that you specified, it usually takes one hour to finish the installation of Cloud Pak for Watson AIOps, and ten minutes to finish all other application deployments, including Ceph, Robot Shop, Humio, Istio, and more. When the Argo CD Apps turn green, (`Synced` and `Healthy`) then the installation of the Cloud Pak for Watson AIOps demonstration environment is finished.

![](images/02-install-complete.png)

## Access Environment

### Cloud Pak for Watson AIOps

To access Cloud Pak for Watson AIOps, you can run following command to get the URL. Here `aiops-installation` is the Cloud Pak for Watson AIOps instance name that you specified using the installation parameter `cp4waiops.instanceName` when creating the Argo CD App.

```sh
kubectl -n cp4waiops get installation aiops-installation -o jsonpath='{.status.locations.cloudPakUiUrl}{"\n"}'
```

To get the password for user `admin`, run following command:

```sh
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d
```

Use this information to log in to the Cloud Pak for Watson AIOps UI.

![](images/waiops-dashbord.png)

If you set the installation parameter `cp4waiops.setup` to `true`, then you have pre-configured an integration with Humio, Kafka, and Kubernetes in. To verify this, go to `Define` > `Data and tool connections` to see these integrations displayed as follows:

![](images/03-pre-configured-connections.png)

### Robot Shop

To access Robot Shop, run the following command to get the URL:

```sh
kubectl -n istio-system get route istio-ingressgateway -o jsonpath='{"http://"}{.spec.host}{"\n"}'
```

![](images/04-robotshop.png)

### Humio

To access Humio, run the following command to get the URL:

```sh
kubectl -n humio-logging get route humio-humio-core -o jsonpath='{"http://"}{.spec.host}{"\n"}'
```

To get the password for user `developer`, run following command:

```sh
kubectl -n humio-logging get secret developer-user-password -o jsonpath="{.data.password}" | base64 -d
```

Use this information to log in to the Humio UI. After logging in, you can see a pre-defined repository named `robot-shop` for Robot Shop:

![](images/05-humio-repo.png)

Click the repository to see the live logs captured by Humio from Robot Shop:

![](images/06-humio-logs.png)
