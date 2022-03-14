<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Customize CP4WAIOps Install](#customize-cp4waiops-install)
  - [Background](#background)
  - [Host Your Own Git Repository](#host-your-own-git-repository)
  - [Advanced Install](#advanced-install)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Customize CP4WAIOps Install

## Background

GitOps is a declarative way to implement continuous deployment for cloud native applications. You can use GitOps to create repeatable processes for managing applications across multiple clusters. GitOps handles and automates complex deployments at a fast pace, saving time during deployment and release cycles.

GitOps is a set of practices that use git pull requests to manage infrastructure and application configurations. In GitOps, the git repository is the only source of truth for system and application configuration. This git repository contains declarative description for the applications you need in your specific environment and contains an automated process to make your environment match the described state. Also, it contains the entire state of the system so that the trail of changes to the system state are visible and auditable. By using GitOps, you solve the issues of application configuration sprawl.

This document provides guidance for customers who want to host the GitOps repositories in their own git systems and customize CP4WAIOps install using their own repositories.

## Host Your Own Git Repository

To customize CP4WAIOps install using your own git repository, you need to follow the steps as below:

- Fork this repository to your own GitHub account.

- Modify parameters in `config/<version>/**/values.yaml` based on your specific install requirement. The [official CP4WAIOps GitOps repository](https://github.com/IBM/cp4waiops-gitops) uses a set of [helm charts](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/) to wrap all CP4WAIOps configuration YAML manifests in multiple helm templates. With helm chart, you can customize the CP4WAIOps install using parameters defined in a set of [`values.yaml`](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/#values-files) files. For example, the [values.yaml](../config/all-in-one/values.yaml) for all-in-one configuration provides a set of parameters with their default values that allow you to customize the CP4WAIOps install using all-in-one configuration.

- Other than modifying the existing `value.yaml` file, you can also define additional `values.yaml` files when needed. These `values.yaml` files along with the original `values.yaml` file can all be applied when you create Argo CD App to kick off the CP4WAIOps install either from UI or command line.

- Follow the installation guide for a certain CP4WAIOps release that is provided in the [official CP4WAIOps GitOps repository](https://github.com/IBM/cp4waiops-gitops) to install CP4WAIOps using GitOps. If you install CP4WAIOps from UI, then when you create the Argo CD App, in the Argo CD App form, change the `Repository URL` field to match the URL of your own repository, and set the `Revision` field to match the branch that you are working on. You can also apply the additional `values.yaml` files defined in previous step by adding them in `HELM` > `VALUES FILES` field in the form.

- If you install CP4WAIOps from command line using Argo CD CLI, you can set the repository and revision using argument `--repo` and `--revision`. For example, if you forked the [official CP4WAIOps GitOps repository](https://github.com/IBM/cp4waiops-gitops) into repository `https://github.com/foo/cp4waiops-gitops`, and work on branch `production`, you would run the following command to create an Argo CD App and kick off the install of CP4WAIOps AI Manager:

  ```sh
  argocd app create cp4waiops-app \
          --sync-policy automatic \
          --project default \
          --repo https://github.com/foo/cp4waiops-gitops \
          --path config/3.3/ai-manager \
          --revision production \
          --dest-namespace cp4waiops \
          --dest-server https://kubernetes.default.svc \
          --helm-set spec.cp4waiops_namespace=cp4waiops \
          --helm-set spec.imageCatalog=icr.io/cpopen/ibm-operator-catalog:latest \
          --helm-set spec.channel=v3.3 \
          --helm-set spec.dockerUsername=cp \
          --helm-set spec.dockerPassword= <entitlement-key> \
          --helm-set spec.storageClass=rook-cephfs \
          --helm-set spec.storageClassLargeBlock=rook-cephfs \
          --helm-set spec.size=small
  ```

## Advanced Install

- [Deploy CP4WAIOps Demo Environment to Multiple Clusters](./deploy-cloudpak-to-multiple-clusters.md)
- [Deploy CP4WAIOps Demo Environment in One Click](./deploy-cloudpak-with-sample-apps.md)
- [Deploy CP4WAIOps Demo Environment Including Cluster Provisioning](./deploy-ocp-cloudpak-with-gitops.md)
