<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Deploy CP4WAIOps Demo Environment In One Click Using GitOps](#deploy-cp4waiops-demo-environment-in-one-click-using-gitops)
  - [Prepare Environment](#prepare-environment)
  - [Install CP4WAIOps](#install-cp4waiops)
    - [Installation Parameters](#installation-parameters)
  - [Access Environment](#access-environment)
    - [CP4WAIOps](#cp4waiops)
    - [Robot Shop](#robot-shop)
    - [Humio](#humio)
- [Deploy CP4WAIOps Demo Environment to Multiple Clusters Using GitOps](#deploy-cp4waiops-demo-environment-to-multiple-clusters-using-gitops)
  - [Prepare Environments](#prepare-environments)
  - [Install Argocd CLI](#install-argocd-cli)
  - [Install CP4WAIOps](#install-cp4waiops-1)
  - [Add Cluster Into Argo CD](#add-cluster-into-argo-cd)
  - [Add More Clusters](#add-more-clusters)
- [Deploy CP4WAIOps Demo Environment With OCP Using GitOps](#deploy-cp4waiops-demo-environment-with-ocp-using-gitops)
  - [Install CP4WAIOps](#install-cp4waiops-2)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Deploy CP4WAIOps Demo Environment In One Click Using GitOps


This tutorial will work you through the extremely easy steps to deploy demo environment for Cloud Pak for Watson AIOps (CP4WAIOps) using GitOps. It allows you to:

- Deploy CP4WAIOps using custom profile, e.g.: extremely small profile in a sandbox with restricted resource.
- Auto-configure integration with Humio, Kafka, Kubernetes, etc. as post-install step.
- Deploy Robot Shop as sample application and other dependencies on the same cluster where CP4WAIOps runs.

Althouth in this tutorial, I will use the extremely small profile to demonstrate the installation of CP4WAIOps, sample application, and dependencies, which is targeted for demo or PoC deployment rather than production deployment, the same idea can be applied to CP4WAIOps installation in production environment as well.

This approach has been tested and verfied on CP4WAIOps 3.3.

![](images/00-demo-env.png)

## Prepare Environment

Prepare an OpenShift cluster as your demo environment. If you use the extremely small profile, i.e.: the `x-small` profile, it is recommended to setup a cluster with 3 worker nodes where each node has 16 core CPU and 32GB memory. We will use this cluster to install below applications:

| Application        | Required | Description
| ------------------ | -------- | -------------------------------------------------------------------
| Argo CD            | Yes      | The GitOps engine that drives the whole installation under the hood.
| Rook Ceph          | No       | The storage used by CP4WAIOps and other applications. It can be skipped if you already have storage provisioned.
| CP4WAIOps          | No       | Cloud Pak for Watson AIOps.
| Robot Shop         | No       | The sample application used to demonstrate CP4WAIOps features.
| Humio & Fluent Bit | No       | The log collector used by CP4WAIOps.
| Istio              | No       | The service mesh used by sample application for fault injection.

## Install CP4WAIOps

Login to Argo CD, you should be able to kick off the installation by clicking the "NEW APP" button on top left to create an Argo Application.

Just fill in the form using the suggested field values listed in below table:

| Field                 | Value                                                 |
| --------------------- | ----------------------------------------------------- |
| Application Name      | cp4waiops-demo                                        |
| Project               | default                                               |
| Sync Policy           | Automatic                                             |
| Repository URL        | https://github.com/IBM/cp4waiops-gitops     |
| Revision              | HEAD                                                  |
| Path                  | config/all-in-one                                     |
| Cluster URL           | https://kubernetes.default.svc                        |
| Namespace             | openshift-gitops                                      |

### Installation Parameters

Besides the basic information that you input, it also allows you to change the installation parameters as below to customize the installation behavior.

For example:

- HELM
  - VALUES
    ```yaml
    robotshop:
      enabled: true
    humio:
      enabled: true
    istio:
      enabled: true
    ```

Below table summarizes the detailed meaning for each parameter:

| Parameter                 | Type   | Default Value      | Description 
| ------------------------- |--------|--------------------|-----------------------------------
| cp4waiops.setup.enabled           | bool   | true               | Specify whether or not to setup CP4WAIOps with sample integrations, e.g.: Humio, Kafka, Kubernetes, etc. after it is installed.
| cp4waiops.setup.humio.enabled  | bool   | true  | Setup Humio integration
| cp4waiops.setup.kafka.enabled   | bool   | true  | Setup Kafka integration
| cp4waiops.setup.kubernetes.enabled  | bool   | true | Setup Kubernetes integration 
| robotshop.enabled         | bool   | true               | Specify whether or not to install Robotshop.
| humio.enabled             | bool   | true               | Specify whether or not to install Humio. 
| istio.enabled             | bool   | true               | Specify whether or not to install Istio.

[here]: https://myibm.ibm.com/products-services/containerlibrary

After you finish filling up the form, just click the "CREATE" button to kick off the installation, then you are done!

Now you can work around, grab some coffee, and wait for the installation to complete. During the time, you will notice a few more argo applications being rolled out gradually from Argo CD UI. Each application represents a specific application to be deployed which is managed by the root level application defined by you as above.

![](images/01-apps.png)

Depends on the installation parameters that you specified, it usually takes 1 hour to finish the installation of CP4WAIOps, and 10 minutes to finish all the other applications deployment including Rook Ceph, Robot Shop, Humio, Istio, etc. When you see all the applications turn into green, i.e.: `Synced` and `Healthy`, that means CP4WAIOps install is completed!

![](images/02-install-complete.png)

## Access Environment

### CP4WAIOps

To access CP4WAIOps, you can run below command to get the URL. Here `aiops-installation` is the CP4WAIOps instance name that you specified via the installation parameter `cp4waiops.instanceName` in above step.

```sh
kubectl -n cp4waiops get installation aiops-installation -o jsonpath='{.status.locations.cloudPakUiUrl}{"\n"}'
```

Run below command to get the password for user `admin`:

```sh
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d
```

Then use these information to login CP4WAIOps UI:

![](images/waiops-dashbord.png)

If you set the installation parameter `cp4waiops.setup` to `true`, then you will have all the pre-configured integration with Humio, Kafka, and Kubernetes in place. To verify this, navigate to `define` -> `Data and tool connections` after you login, you can see all the integrations created as below:

![](images/03-pre-configured-connections.png)

### Robot Shop

To access Robot Shop, you can run below command to get the URL:

```sh
kubectl -n istio-system get route istio-ingressgateway -o jsonpath='{"http://"}{.spec.host}{"\n"}'
```

![](images/04-robotshop.png)

### Humio

To access Humio, you can run below command to get the URL:

```sh
kubectl -n humio-logging get route humio-humio-core -o jsonpath='{"http://"}{.spec.host}{"\n"}'
```

Run below command to get the password for user `developer`:

```sh
kubectl -n humio-logging get secret developer-user-password -o jsonpath="{.data.password}" | base64 -d
```

After login to Humio UI, you will see the pre-defined repo named `robot-shop` for Robot Shop sample application:

![](images/05-humio-repo.png)

Click the repo, you will see the live logs captured by Humio from Robot Shop:

![](images/06-humio-logs.png)


# Deploy CP4WAIOps Demo Environment to Multiple Clusters Using GitOps

This tutorial will work you through the steps to deploy the same demo environment for Cloud Pak for Watson AIOps (CP4WAIOps) to multiple clusters using GitOps. You will see that to deploy CP4WAOps, sample application, and other dependencies to multiple clusters is extremely easy.

## Prepare Environments

You need at least one cluster to host Argo CD, then one or more clusters to deploy the CP4WAIOps demo environment. As it is illustrated in below diagram:

* `cluster 0` is used to host the Argo CD instance. It can be an OpenShift or a vanilla Kubernetes cluster which does not require too much resource since Argo CD is a very lightweight application and support both OpenShift and vanilla Kubernetes.

* `cluster 1` to `cluster X` are used to deploy the CP4WAIOps demo environments. If you are looking for an extremely small CP4WAIOps deployment with all the default components, sample application, and other dependencies run on the same cluster for demo or PoC purpose, it is recommended to prepare cluster with 3 worker nodes where each node has 16 core CPU and 32GB memory. If you are looking for production deployment, please refer to the hardware requirement details in the official [product document](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.3.0?topic=requirements-ai-manager).

![](images/07-deploy-to-multiple-clusters.png)

## Install Argocd CLI

In this tutorial, we will also use argocd CLI to add clusters to Argo CD so that Argo CD can deploy the CP4WAIOps demo environment to those clusters. To install argocd CLI, please refer to the [Argo CD online document](https://argo-cd.readthedocs.io/en/stable/cli_installation/). You can install and run argocd CLI on any machine such as your notebook, since it is just a client tool used to connect to Argo CD server.

## Install CP4WAIOps

After you finish the Argo CD and argocd CLI install, let's deploy CP4WAIOps via Argo CD UI. To install CP4WAIOps, please refer to the `Install CP4WAIOps` section in [this document](how-to-deploy-cp4waiops-33.md). We use the same field values described in that document when filling up the form to create the Argo Application.

The only difference is, when you set the installation parameter `argocd.allowLocalDeploy`, make sure it is `false`. This is to avoid the CP4WAIOps demo environment from being deployed on the same cluster where Argo CD runs, since in this tutorial, we use that cluster to run Argo CD dedicately.

After you create the Argo Application, you will see something similar as below from Argo CD UI:

![](images/08-deploy-appsets.png)

You will only see the root level Argo Application is listed. There is no other child level Applications created for now. This is because we have not added any other cluters into Argo CD to deploy the actual CP4WAIOps demo environments yet. But if you click the root level application and go into it, you will see all the child level application definitions are listed as below:

![](images/09-appsets.png)

Depends on the installation parameters that you specified when you create the root level Argo Application, you can enable or disable some of the applications according to your specific needs. In the above case, I enabled all applications that are available, e.g.: CP4WAIOps, Robot Shop, Humio, Istio, etc. They will be deployed to target cluster that is going to be added into Argo CD later in this tutorial.

## Add Cluster Into Argo CD

Let's add our first cluster into Argo CD. Suppose you use OpenShift cluster to host Argo CD, you need to login to the cluster first using `oc login` command, then run below command to login to Argo CD using argocd CLI:

```sh
ARGO_HOST=$(oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}')
ARGO_PASSWORD=$(oc get secret openshift-gitops-cluster -n openshift-gitops -o "jsonpath={.data['admin\.password']}" | base64 -d)
argocd login --username admin --password $ARGO_PASSWORD $ARGO_HOST --insecure
```

Next, login to the target cluster that will be used to deploy the CP4WAIOps demo environment, again using `oc login` command. Then, run below command to add that cluster into Argo CD using argocd CLI:

```sh
CLUSTER_NAME=stocky
CURRENT_CONTEXT=$(oc config current-context)
argocd cluster add $CURRENT_CONTEXT --name $CLUSTER_NAME
```

Here, let's give the cluster a short name using `CLUSTER_NAME` and pass it into argocd CLI via argument `--name`.

Now, go to `Settings` -> `Clusters` from Argo CD UI, you will see the newly added cluster is listed as below:

![](images/10-add-1st-cluster-to-argocd.png)

If you go to `Applications`, all of a sudden, you will see all the child level applications are getting created and that all happens automatically without any additional manual intervention.

![](images/11-apps-on-1st-cluster.png)

If you click the root level application and go into it, you will see for each child level application definition, there is a corresponding application instance linked to it and that is the actual workload being deployed to the target cluster that we added into Argo CD just now.

![](images/12-deploy-to-1st-cluster.png)

Depends on the installation parameters that you specified when creating the root level application, it usually takes 1 hour to finish the installation of CP4WAIOps, and 10 minutes to finish all the other applications deployment including Rook Ceph, Robot Shop, Humio, Istio, etc. When you see all the applications turn into green, i.e.: `Synced` and `Healthy`, that means the CP4WAIOps demo environment install is completed on the target cluster!

![](images/13-install-complete.png)

## Add More Clusters

To add more clusters to deploy more CP4WAIOps demo environments is quite easy. Just repeat the above step to add clusters into Argo CD. Once detected, Argo CD will deploy applications to these clusters automatically. As an example, after you add the second cluster, you will see the newly added cluster will be added to the `Clusters` view from Argo CD UI:

![](images/14-add-2nd-cluster-to-argocd.png)

You will also see each child level application definition now maps to two application instances and each instance represents the actual workload being deployed to a separate cluster.

![](images/15-deploy-to-2nd-cluster.png)

# Deploy CP4WAIOps Demo Environment With OCP Using GitOps

This tutorial will work you through the steps to provision an OpenShift cluster, then use this cluster to deploy the demo environment for Cloud Pak for Watson AIOps (CP4WAIOps) using GitOps. With this approach, you will get a fully automated experience of launching a CP4WAIOps demo environment from end to end, started from cluster provisioning, till to the demo environment deployment, and configuration, all driven by GitOps automatically.

![](images/16-architecture-provision-cluster.png)


## Install CP4WAIOps

After you finish the Argo CD install, you can deploy CP4WAIOps via Argo CD UI. To install CP4WAIOps, please refer to the `Install CP4WAIOps` section in [this document](how-to-deploy-cp4waiops-33.md). We use the same field values described in that document when filling up the form to create the Argo Application.

The only difference happens when you set the installation parameters:

Firstly, you may need to make sure the installation parameter `argocd.allowLocalDeploy` is `false`. This is to avoid the CP4WAIOps demo environment from being deployed on the same cluster where Argo CD runs, since in this tutorial, we use that cluster to run Argo CD dedicately.

Secondly, you will be able to configure the OpenShift cluster provisioning using below additional parameters.

| Parameter                                        | Type   | Default Value | Description 
| ------------------------------------------------ |--------|---------------|-----------------------------------
| cluster.enabled                                  | bool   | false         | Specify whether or not to provision a cluster before install CP4WAIOps.
| cluster.provider.fyre.credentials.productGroupId | string | n/a           | Fyre product group id required when calling Fyre API
| cluster.provider.fyre.credentials.token          | string | n/a           | Fyre user token required when calling Fyre API
| cluster.provider.fyre.credentials.user           | string | n/a           | Fyre user id required when calling Fyre API

After you create the Argo Application, you will see something similar as below from Argo CD UI:

![](images/17-apps-provision-cluster.png)

Apart from the root level application, the application `cluster-operator-fyre` represents the operator that drives the cluster provisioning on Fyre. The application `clusters-fyre` maps the cluster provisioning request that we created and stored in git repository. Click the `clusters-fyre` application to check its details:

![](images/18-cluster-provision-request.png)

There is a custom resource in type of `OpenShiftFyre` that "documents" the desired status for the OpenShift cluster that we request. Also, there is a secret that includes the Fyre credentials that we input earlier when creating the Argo Application using installation parameters. The operator will use this information to communicate with Fyre API. You may also notice that the `OpenShiftFyre` resource is in `Processing` status. This means the operator has issued the request to Fyre successfully and Fyre has started to provision the cluster for us.

If you go to the root level application, you will see that two new child level applications are added:

![](images/19-appsets-cluster-provision.png)

Because the cluster is still being provisioned and not available to deploy the CP4WAIOps demo environment yet, there's no actual application instance spawned for the demo environment, e.g.: the instane for CP4WAIOps, Robot Shop, Humio, Istio, etc. Usually, it takes time to complete the cluster provisioning. Once it's completed, the new cluster will be added into Argo CD automatically by the operator. You can check it by going to `Settings` -> `Clusters` from Argo CD UI:

![](images/20-cluster-auto-added.png)

When the new cluster is displayed in the list as above, Argo CD will then kick off the demo environment deployment on that cluster immediately without any manual intervention. You will see all child level applications are now getting created from the `Applications` view as below:

![](images/21-deploy-appsets.png)

Specify the target cluster in the clusters filter box, then wait for all applications turning into green.

![](images/22-install-complete.png)

Now you should be able to use your fresh new CP4WAIOps demo environment. Enjoy it!

