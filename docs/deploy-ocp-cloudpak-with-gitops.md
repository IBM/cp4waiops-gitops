<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Deploy Cloud Pak for Watson AIOPs Demo Environment Including Cluster Provisioning](#deploy-cp4waiops-demo-environment-including-cluster-provisioning)
  - [Install Cloud Pak for Watson AIOPs Demo Environment](#install-cp4waiops-demo-environment)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Deploy Cloud Pak for Watson AIOPs demo environment including cluster provisioning

Learn how to provision a Red Hat OpenShift cluster, and use this cluster to deploy an IBM Cloud Pak for Watson AIOPs demonstration environment using GitOps. With this approach you will get a fully automated experience of launching a Cloud Pak for Watson AIOPs demo environment, from cluster provisioning to the deployment and configuration of the demonstration environment, all driven by GitOps automatically.

**IMPORTANT: Internal use only. `Fyre`, an IBM IaaS platform for internal use, is currently the only supported provider.**

![](images/16-architecture-provision-cluster.png)

## Install Cloud Pak for Watson AIOPs demo environment

After installing Argo CD, you can deploy a Cloud Pak for Watson AIOPs demonstration environment via Argo CD UI. To install a Cloud Pak for Watson AIOPs demonstration environment, please refer to [Install Cloud Pak for Watson AIOPs demo environment](#install-cp4waiops-demo-environment).

The only difference when you set the install parameters is that:

- `argocd.allowLocalDeploy` must be set to `false`. This is to avoid the Cloud Pak for Watson AIOps demonstration environment from being deployed on the same cluster where Argo CD runs, since in this case, that cluster is dedicated to running Argo CD.
- You will be able to configure the Red Hat OpenShift cluster provisioning with the following installation parameters.

| Parameter                                   | Type   | Default Value | Description 
| ------------------------------------------- |--------|---------------|-----------------------------------
| cluster.enabled                             | bool   | false         | Specify whether or not to provision a cluster before install Cloud Pak for Watson AIOPs.
| cluster.provider.type                       | string | fyre          | The supported provider to provision cluster, valid values include: fyre.
| cluster.provider.quotaType                  | string | quick-burn    | The supported quota type to provision cluster, valid values include: quick-burn, ocp-plus.
| cluster.provider.credentials.productGroupId | string | REPLACE_IT    | Fyre product group id required when calling Fyre API.
| cluster.provider.credentials.token          | string | REPLACE_IT    | Fyre user token required when calling Fyre API.
| cluster.provider.credentials.user           | string | REPLACE_IT    | Fyre user id required when calling Fyre API.
| cluster.provider.site           | string | svl   | Fyre site required when calling Fyre API, ocp-plus only.
| cluster.provider.ocpVersion           | string | 4.8.27    | OCP Version required when calling Fyre API.
| cluster.provider.workerFlavor           | string | extra-large    | The supported size to provision cluster, valid values include: extra-large, large. extra-large requests 6 worker nodes, large requests 3 worker nodes.

NOTE: `cluster.provider.type`, `fyre` is currently the only supported provider. It is an IBM IaaS platform only for internal use.

These parameters are invisible when you create the Argo CD App from the UI. You can add them when completing the form in `HELM` > `VALUES` field as follows:

```yaml
cluster:
  enabled: true
  provider:
    type: fyre
    quotaType: quick-burn
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

Because the cluster is still being provisioned and not available to deploy the Cloud Pak for Watson AIOPs demo environment yet, there is no actual App instance spawned for the demo environment. Usually, it takes time to complete the cluster provisioning. Once it's completed, the new cluster will be added to Argo CD automatically by the operator. You can check it by going to `Settings` > `Clusters` from Argo CD UI:

![](images/20-cluster-auto-added.png)

When the new cluster is displayed in the list as above, Argo CD will then kick off the demo environment deployment on that cluster immediately without any manual intervention. You will see all child level Apps are now getting created from the `Applications` view as follows:

![](images/21-deploy-appsets.png)

Specify the target cluster in the clusters filter box, then wait for all Apps turning into green.

![](images/22-install-complete.png)

Now you should be able to use your fresh new Cloud Pak for Watson AIOPs demo environment!
