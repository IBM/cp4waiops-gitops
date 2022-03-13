<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [CP4WAIOps Advanced Install Options Using GitOps](#cp4waiops-advanced-install-options-using-gitops)
  - [Deploy CP4WAIOps Demo Environment in One Click](#deploy-cp4waiops-demo-environment-in-one-click)
    - [Prepare Environment](#prepare-environment)
    - [Install CP4WAIOps Demo Environment](#install-cp4waiops-demo-environment)
    - [Access Environment](#access-environment)
      - [CP4WAIOps](#cp4waiops)
      - [Robot Shop](#robot-shop)
      - [Humio](#humio)
  - [Deploy CP4WAIOps Demo Environment to Multiple Clusters](#deploy-cp4waiops-demo-environment-to-multiple-clusters)
    - [Prepare Environments](#prepare-environments)
    - [Install Argocd CLI](#install-argocd-cli)
    - [Install CP4WAIOps Demo Environment](#install-cp4waiops-demo-environment-1)
    - [Add Cluster Into Argo CD](#add-cluster-into-argo-cd)
    - [Add More Clusters](#add-more-clusters)
  - [Deploy CP4WAIOps Demo Environment Including Cluster Provisioning](#deploy-cp4waiops-demo-environment-including-cluster-provisioning)
    - [Install CP4WAIOps Demo Environment](#install-cp4waiops-demo-environment-2)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# CP4WAIOps Advanced Install Options Using GitOps

This document is aimed to introduce different advanced install options for IBM Cloud Pak for Watson AIOps (CP4WAIOps) using GitOps.

## Deploy CP4WAIOps Demo Environment in One Click

In this section, you will learn the extremely easy steps to deploy CP4WAIOps demo environment using GitOps in one click. It allows you to:

- Deploy CP4WAIOps using custom profile `x-small` in a sandbox with restricted resource.
- Setup integration with Humio, Kafka, Kubernetes, etc. as post-install step automatically.
- Deploy Robot Shop as sample application and other dependencies on the same cluster where CP4WAIOps runs.

This install scenario has been tested and verfied against CP4WAIOps 3.2 and 3.3.

![](images/00-demo-env.png)

### About X-Small Profile

The `x-small` profile is not an official profile supported by CP4WAIOps at the moment. It only covers AI Manager and does not include Event Manager. As an experimental feature, you can use it to setup demo, PoC, or dev environment.

Althougth in this install scenario, `x-small` profile is used, this approach also supports CP4WAIOps install in production environment using official profile such as `small` or `large`.

### Prepare Environment

Prepare an OpenShift cluster as your demo environment. If you use `x-small` profile, it is recommended to setup a cluster with 3 worker nodes where each node has 16 cores CPU and 32GB memory.

Before you start to install demo environment, make sure you have installed OpenShift GitOps (Argo CD) on the cluster. To install OpenShift GitOps, please refer to [Installing OpenShift GitOps](https://docs.openshift.com/container-platform/4.8/cicd/gitops/installing-openshift-gitops.html).

We will use Argo CD to install following applications in one go:

| Application        | Required | Description
| ------------------ | -------- | -------------------------------------------------------------------
| Ceph               | No       | The storage used by CP4WAIOps and other applications. It can be skipped if you already have storage solution available on your target cluster.
| CP4WAIOps          | Yes      | IBM Cloud Pak for Watson AIOps.
| Robot Shop         | No       | The sample application used to demonstrate CP4WAIOps features.
| Humio & Fluent Bit | No       | The log collector used by CP4WAIOps for log anomaly detecting.
| Istio              | No       | The service mesh used by sample application for fault injection.

### Install CP4WAIOps Demo Environment

Login to Argo CD, then kick off the install by clicking the `NEW APP` button on top left to create an Argo CD App.

Just fill in the form using the suggested field values listed in following table:

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

- For `repository URL` and `revision` field, if you use a repository forked from [the official CP4WAIOps GitOps repository](https://github.com/IBM/cp4waiops-gitops) and/or on a different branch, please fill these fields using your own values. For example, if you use `https://github.com/<myaccount>/cp4waiops-gitops` and `dev` branch, the two fields need to be changed accordingly.

Besides the basic information, when filling in the form, you can also update the following install parameters that are commonly used to customize the install behavior.

| Parameter                             | Type   | Default Value      | Description 
| ------------------------------------- |--------|--------------------|-------------
| argocd.cluster                        | string | openshift          | The type of the cluster that Argo CD runs on, valid values include: openshift, kubernetes.
| argocd.allowLocalDeploy               | bool   | true               | Allow apps to be deployed on the same cluster where Argo CD runs.
| rookceph.enabled                      | bool   | true               | Specify whether or not to install Ceph as storage used by CP4WAIOps.
| cp4waiops.version                     | string | v3.3               | Specify the version of CP4WAIOps, e.g.: v3.2, v3.3.
| cp4waiops.profile                     | string | small              | The CP4WAIOps deployment profile, e.g.: x-small, small, large.
| cp4waiops.dockerUsername              | string | cp                 | The username of image registry used to pull images.
| cp4waiops.dockerPassword              | string | REPLACE_IT         | The password of image registry used to pull images.
| cp4waiops.aiManager.enabled           | bool   | true               | Specify whether or not to install AI Manager.
| cp4waiops.aiManager.namespace         | string | cp4waiops          | The namespace where AI Manager is installed.
| cp4waiops.aiManager.instanceName      | string | aiops-installation | The instance name of AI Manager.
| cp4waiops.eventManager.enabled        | bool   | true               | Specify whether or not to install Event Manager.
| cp4waiops.eventManager.namespace      | string | noi                | The namespace where Event Manager is installed.
| cp4waiops.eventManager.clusterDomain  | string | REPLACE_IT         | The domain name of the cluster where Event Manager is installed.

NOTE:

- For `cp4waiops.dockerPassword`, it is the entitlement key that you can copy from [My IBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary).
- For `cp4waiops.profile`, the profile `x-small` is only for demo, PoC, or dev environment. If you are looking for official installation, use profile such as `small` or `large` instead.
- For `cp4waiops.eventManager.enabled`, it needs to be false if you use `x-small` profile as it only covers AI Manager, not including Event Manager.
- For `cp4waiops.eventManager.clusterDomain`, it is the domain name of the cluster where Event Manager is installed. Use fully qualified domain name (FQDN), e.g.: apps.clustername.abc.xyz.com.

The following install parameters are not commonly used, so they are invisible when you create the Argo CD App from UI. But you can add them when filling in the form in `HELM` > `VALUES` field.

| Parameter                          | Type   | Default Value  | Description 
| ---------------------------------- |--------|----------------|-------------
| cp4waiops.setup.enabled            | bool   | false          | Setup CP4WAIOps after it is installed.
| cp4waiops.setup.humio.enabled      | bool   | true           | Setup Humio integration.
| cp4waiops.setup.kafka.enabled      | bool   | true           | Setup Kafka integration.
| cp4waiops.setup.kubernetes.enabled | bool   | true           | Setup Kubernetes integration. 
| robotshop.enabled                  | bool   | false          | Specify whether or not to install Robot Shop.
| humio.enabled                      | bool   | false          | Specify whether or not to install Humio. 
| istio.enabled                      | bool   | false          | Specify whether or not to install Istio.

For example, adding following YAML snippet to `HELM` > `VALUES` field will enable Robot Shop, Humio, and Istio: 

```yaml
robotshop:
  enabled: true
humio:
  enabled: true
istio:
  enabled: true
```

After you finish filling up the form, just click the `CREATE` button to kick off the install, then you are done! During the time when waiting for the install to complete, you will see more Apps being rolled out gradually from Argo CD UI. Each App represents a specific application to be deployed and is managed by the root level App defined as above.

![](images/01-apps.png)

Depends on the install parameters that you specified, it usually takes 1 hour to finish the install of CP4WAIOps, and 10 minutes to finish all other applications deployment including Ceph, Robot Shop, Humio, Istio, etc. When you see all Argo CD Apps turning into green, i.e.: `Synced` and `Healthy`, that means CP4WAIOps demo environment install is completed!

![](images/02-install-complete.png)

### Access Environment

#### CP4WAIOps

To access CP4WAIOps, you can run following command to get the URL. Here `aiops-installation` is the CP4WAIOps instance name that you specified using the install parameter `cp4waiops.instanceName` when creating the Argo CD App.

```sh
kubectl -n cp4waiops get installation aiops-installation -o jsonpath='{.status.locations.cloudPakUiUrl}{"\n"}'
```

To get the password for user `admin`, run following command:

```sh
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d
```

Then use these information to login CP4WAIOps UI:

![](images/waiops-dashbord.png)

If you set the install parameter `cp4waiops.setup` to `true`, then you will have pre-configured integration with Humio, Kafka, Kubernetes in place. To verify this, navigate to `define` > `Data and tool connections` after you login, you will see all integrations displayed as follows:

![](images/03-pre-configured-connections.png)

#### Robot Shop

To access Robot Shop, you can run following command to get the URL:

```sh
kubectl -n istio-system get route istio-ingressgateway -o jsonpath='{"http://"}{.spec.host}{"\n"}'
```

![](images/04-robotshop.png)

#### Humio

To access Humio, you can run following command to get the URL:

```sh
kubectl -n humio-logging get route humio-humio-core -o jsonpath='{"http://"}{.spec.host}{"\n"}'
```

To get the password for user `developer`, run following command:

```sh
kubectl -n humio-logging get secret developer-user-password -o jsonpath="{.data.password}" | base64 -d
```

Then use these information to login Humio UI. After login, you will see the pre-defined repo named `robot-shop` for Robot Shop:

![](images/05-humio-repo.png)

Click the repo, you will see the live logs captured by Humio from Robot Shop:

![](images/06-humio-logs.png)

## Deploy CP4WAIOps Demo Environment to Multiple Clusters

In this section, you will learn the steps to deploy the same CP4WAIOps demo environment to multiple clusters using GitOps with almost zero effort. You will see that to deploy CP4WAOps, sample application, and other dependencies to multiple clusters is extremely easy.

### Prepare Environments

To support this install scenario, you need at least one cluster to host Argo CD, and one or more clusters to deploy the CP4WAIOps demo environment, which is illustrated in following diagram:

![](images/07-deploy-to-multiple-clusters.png)

NOTE:

* `cluster 0` is used to host the Argo CD instance. It can be an OpenShift cluster or a vanilla Kubernetes cluster which does not require too much resource since Argo CD is very lightweight and supports both OpenShift and vanilla Kubernetes.
* `cluster 1` to `cluster x` are used to deploy CP4WAIOps demo environments. If you are looking for an extremely small CP4WAIOps deployment with all default components, sample application, and other dependencies run on the same cluster for demo or PoC purpose, it is recommended to prepare cluster with 3 worker nodes where each node has 16 cores CPU and 32GB memory. If you are looking for production deployment, please refer to the system requirement details from the official [product document](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.3.0?topic=requirements-ai-manager).

### Install Argocd CLI

In this case, you will need Argo CD CLI, i.e.: the `argocd` command, to add clusters to Argo CD, so that Argo CD can deploy the CP4WAIOps demo environment to those clusters. To install Argo CD CLI, please refer to the [Argo CD online document](https://argo-cd.readthedocs.io/en/stable/cli_installation/). You can install and run Argo CD CLI on any machine such as your notebook, since it is just a client tool used to connect to the Argo CD server.

### Install CP4WAIOps Demo Environment

After finish the install of Argo CD and Argo CD CLI, you can deploy CP4WAIOps demo environment via Argo CD UI. To install CP4WAIOps demo environment, please refer to [Install CP4WAIOps Demo Environment](#install-cp4waiops-demo-environment).

The only difference when you set the install parameters is that:

- For `argocd.allowLocalDeploy`, make sure it is `false`. This is to avoid the CP4WAIOps demo environment from being deployed on the same cluster where Argo CD runs, since in this case, that cluster is used to run Argo CD dedicately.

After you create the Argo CD App, you will see something similar as follows from Argo CD UI:

![](images/08-deploy-appsets.png)

You will only see the root level Argo CD App. There is no other child level Apps created for now. This is because there is no other cluter added into Argo CD to deploy the actual CP4WAIOps demo environment yet. But if you click the root level App and go into it, you will see all child level App definitions are listed as follows:

![](images/09-appsets.png)

Depends on the install parameters that you specified when you create the root level Argo CD App, you can enable or disable some of the Apps according to your specific needs. In this case, all available Apps are enabled indlucing CP4WAIOps, Robot Shop, Humio, Istio, etc. They will be deployed to the target cluster that is going to be added into Argo CD later.

### Add Cluster Into Argo CD

Suppose you use OpenShift cluster to host Argo CD. To add the cluster into Argo CD, you need to login to the cluster that runs Argo CD using `oc login` command, then run following commands to login to Argo CD using Argo CD CLI:

```sh
ARGO_HOST=$(oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}')
ARGO_PASSWORD=$(oc get secret openshift-gitops-cluster -n openshift-gitops -o "jsonpath={.data['admin\.password']}" | base64 -d)
argocd login --username admin --password $ARGO_PASSWORD $ARGO_HOST --insecure
```

Next, login to the target cluster that will be used to deploy the CP4WAIOps demo environment, again using `oc login` command. Then, run following commands to add that cluster into Argo CD using Argo CD CLI:

```sh
CLUSTER_NAME=stocky
CURRENT_CONTEXT=$(oc config current-context)
argocd cluster add $CURRENT_CONTEXT --name $CLUSTER_NAME
```

Here, a short name for the cluster is given using `CLUSTER_NAME` and is passed into Argo CD CLI via argument `--name`.

Now, go to `Settings` > `Clusters` from Argo CD UI, you will see the newly added cluster is listed as follows:

![](images/10-add-1st-cluster-to-argocd.png)

If you go to `Applications`, all of a sudden, you will see all child level Apps are getting created and that all happens automatically without any additional manual intervention.

![](images/11-apps-on-1st-cluster.png)

If you click the root level App and go into it, you will see for each child level App definition, there is a corresponding App instance linked to it and that is the actual application getting deployed to the target cluster that was added into Argo CD just now.

![](images/12-deploy-to-1st-cluster.png)

Depends on the install parameters that you specified when creating the root level App, it usually takes 1 hour to finish the install of CP4WAIOps, and 10 minutes to finish all the other applications deployment including Ceph, Robot Shop, Humio, Istio, etc. When you see all Apps turning into green, i.e.: `Synced` and `Healthy`, that means the CP4WAIOps demo environment install is completed on the target cluster!

![](images/13-install-complete.png)

### Add More Clusters

To add more clusters to deploy more CP4WAIOps demo environments is quite easy. Just repeat the above step to add clusters into Argo CD. Once detected by Argo CD, it will deploy applications to these clusters automatically. As an example, after you add the second cluster, you will see the newly added cluster will be added to the `Clusters` view from Argo CD UI:

![](images/14-add-2nd-cluster-to-argocd.png)

You will also see each child level App definition now maps to two App instances and each instance represents the actual application that is getting deployed to a separate cluster.

![](images/15-deploy-to-2nd-cluster.png)

## Deploy CP4WAIOps Demo Environment Including Cluster Provisioning

In this section, you will learn the steps to provision an OpenShift cluster, then use this cluster to deploy CP4WAIOps demo environment using GitOps. With this approach, you will get a fully automated experience of launching a CP4WAIOps demo environment, started from cluster provisioning, till to the demo environment deployment, and configuration, all driven by GitOps automatically.

![](images/16-architecture-provision-cluster.png)

### Install CP4WAIOps Demo Environment

After finish the install of Argo CD, you can deploy CP4WAIOps demo environment via Argo CD UI. To install CP4WAIOps demo environment, please refer to [Install CP4WAIOps Demo Environment](#install-cp4waiops-demo-environment).

The only difference when you set the install parameters is that:

- For `argocd.allowLocalDeploy`, make sure it is `false`. This is to avoid the CP4WAIOps demo environment from being deployed on the same cluster where Argo CD runs, since in this case, that cluster is used to run Argo CD dedicately.
- You will be able to configure the OpenShift cluster provisioning using following install parameters.

| Parameter                                   | Type   | Default Value | Description 
| ------------------------------------------- |--------|---------------|-----------------------------------
| cluster.enabled                             | bool   | false         | Specify whether or not to provision a cluster before install CP4WAIOps.
| cluster.provider.type                       | string | fyre          | The supported provider to provision cluster, valid values include: fyre.
| cluster.provider.credentials.productGroupId | string | REPLACE_IT    | Fyre product group id required when calling Fyre API.
| cluster.provider.credentials.token          | string | REPLACE_IT    | Fyre user token required when calling Fyre API.
| cluster.provider.credentials.user           | string | REPLACE_IT    | Fyre user id required when calling Fyre API.

NOTE:

- For `cluster.provider.type`, `fyre` is currently the only supported provider. It is an IBM IaaS platform only for internal use.

These parameters are invisible when you create the Argo CD App from UI. You can add them when filling in the form in `HELM` > `VALUES` field as follows:

```yaml
cluster:
  enabled: true
  provider:
    type: fyre
    credentials:
      user: <my_user_id>
      token: <my_user_token>
      productGroupId: <my_product_group_id>
```

After you create the Argo CD App, you will see something similar as follows from Argo CD UI:

![](images/17-apps-provision-cluster.png)

Apart from the root level App, the App `cluster-operator-fyre` represents the operator that drives the cluster provisioning on Fyre. The App `clusters-fyre` maps the cluster provisioning request created and stored in git repository. Click the App `clusters-fyre` to check its details:

![](images/18-cluster-provision-request.png)

There is a custom resource in type of `OpenShiftFyre` that "documents" the desired status for the OpenShift cluster to be requested. Also, there is a secret that includes the Fyre credentials that you input earlier when creating the Argo CD App using install parameters. The operator will use this information to communicate with Fyre API. You may also notice that the `OpenShiftFyre` resource is in `Processing` status. This means the operator has issued the request to Fyre successfully and Fyre has started to provision the cluster for you.

If you go to the root level App, you will see that two new child level Apps are added:

![](images/19-appsets-cluster-provision.png)

Because the cluster is still being provisioned and not available to deploy the CP4WAIOps demo environment yet, there is no actual App instance spawned for the demo environment. Usually, it takes time to complete the cluster provisioning. Once it's completed, the new cluster will be added to Argo CD automatically by the operator. You can check it by going to `Settings` > `Clusters` from Argo CD UI:

![](images/20-cluster-auto-added.png)

When the new cluster is displayed in the list as above, Argo CD will then kick off the demo environment deployment on that cluster immediately without any manual intervention. You will see all child level Apps are now getting created from the `Applications` view as follows:

![](images/21-deploy-appsets.png)

Specify the target cluster in the clusters filter box, then wait for all Apps turning into green.

![](images/22-install-complete.png)

Now you should be able to use your fresh new CP4WAIOps demo environment!
