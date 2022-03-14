<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Deploy CP4WAIOps Demo Environment to Multiple Clusters](#deploy-cp4waiops-demo-environment-to-multiple-clusters)
  - [Prepare Environments](#prepare-environments)
  - [Install Argocd CLI](#install-argocd-cli)
  - [Install CP4WAIOps Demo Environment](#install-cp4waiops-demo-environment)
  - [Add Cluster Into Argo CD](#add-cluster-into-argo-cd)
  - [Add More Clusters](#add-more-clusters)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Deploy CP4WAIOps Demo Environment to Multiple Clusters

In this section, you will learn the steps to deploy the same CP4WAIOps demo environment to multiple clusters using GitOps with almost zero effort. You will see that to deploy CP4WAOps, sample application, and other dependencies to multiple clusters is extremely easy.

## Prepare Environments

To support this install scenario, you need at least one cluster to host Argo CD, and one or more clusters to deploy the CP4WAIOps demo environment, which is illustrated in following diagram:

![](images/07-deploy-to-multiple-clusters.png)

NOTE:

* `cluster 0` is used to host the Argo CD instance. It can be an OpenShift cluster or a vanilla Kubernetes cluster which does not require too much resource since Argo CD is very lightweight and supports both OpenShift and vanilla Kubernetes.
* `cluster 1` to `cluster x` are used to deploy CP4WAIOps demo environments. If you are looking for an extremely small CP4WAIOps deployment with all default components, sample application, and other dependencies run on the same cluster for demo or PoC purpose, it is recommended to prepare cluster with 3 worker nodes where each node has 16 cores CPU and 32GB memory. If you are looking for production deployment, please refer to the system requirement details from the official [product document](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.3.0?topic=requirements-ai-manager).

## Install Argocd CLI

In this case, you will need Argo CD CLI, i.e.: the `argocd` command, to add clusters to Argo CD, so that Argo CD can deploy the CP4WAIOps demo environment to those clusters. To install Argo CD CLI, please refer to the [Argo CD online document](https://argo-cd.readthedocs.io/en/stable/cli_installation/). You can install and run Argo CD CLI on any machine such as your notebook, since it is just a client tool used to connect to the Argo CD server.

## Install CP4WAIOps Demo Environment

After finish the install of Argo CD and Argo CD CLI, you can deploy CP4WAIOps demo environment via Argo CD UI. To install CP4WAIOps demo environment, please refer to [Install CP4WAIOps Demo Environment](#install-cp4waiops-demo-environment).

The only difference when you set the install parameters is that:

- For `argocd.allowLocalDeploy`, make sure it is `false`. This is to avoid the CP4WAIOps demo environment from being deployed on the same cluster where Argo CD runs, since in this case, that cluster is used to run Argo CD dedicately.

After you create the Argo CD App, you will see something similar as follows from Argo CD UI:

![](images/08-deploy-appsets.png)

You will only see the root level Argo CD App. There is no other child level Apps created for now. This is because there is no other cluter added into Argo CD to deploy the actual CP4WAIOps demo environment yet. But if you click the root level App and go into it, you will see all child level App definitions are listed as follows:

![](images/09-appsets.png)

Depends on the install parameters that you specified when you create the root level Argo CD App, you can enable or disable some of the Apps according to your specific needs. In this case, all available Apps are enabled indlucing CP4WAIOps, Robot Shop, Humio, Istio, etc. They will be deployed to the target cluster that is going to be added into Argo CD later.

## Add Cluster Into Argo CD

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

## Add More Clusters

To add more clusters to deploy more CP4WAIOps demo environments is quite easy. Just repeat the above step to add clusters into Argo CD. Once detected by Argo CD, it will deploy applications to these clusters automatically. As an example, after you add the second cluster, you will see the newly added cluster will be added to the `Clusters` view from Argo CD UI:

![](images/14-add-2nd-cluster-to-argocd.png)

You will also see each child level App definition now maps to two App instances and each instance represents the actual application that is getting deployed to a separate cluster.

![](images/15-deploy-to-2nd-cluster.png)
