<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Deploy CP4WAIOps Demo Environment With OCP Using GitOps](#deploy-cp4waiops-demo-environment-with-ocp-using-gitops)
  - [Install CP4WAIOps](#install-cp4waiops)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

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