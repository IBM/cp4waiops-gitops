<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Customize Cloud Pak for Watson AIOps installation](#customize-cp4waiops-install)
  - [Background](#background)
  - [Host Your Own Git Repository](#host-your-own-git-repository)
  - [Advanced Install](#advanced-install)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Customize Cloud Pak for Watson AIOps installation

## Background

GitOps is a declarative way to implement continuous deployment for cloud native applications. You can use GitOps to create repeatable processes for managing applications across multiple clusters. GitOps handles and automates complex deployments at a fast pace, saving time during deployment and release cycles.

GitOps is a set of practices that use Git pull requests to manage infrastructure and application configurations. In GitOps, the Git repository is the only source of truth for system and application configuration. This Git repository contains declarative description for the applications that you need in your specific environment and contains an automated process to make your environment match the described state. Also, it contains the entire state of the system so that the trail of changes to the system state is visible and auditable. With GitOps you can solve the problem of application configuration sprawl.

This document provides guidance for users who want to host the GitOps repositories in their own Git systems and customize an IBM Cloud Pak for Watson AIOps installation from their own repositories.

## Host your own Git repository

To customize a Cloud Pak for Watson AIOps installation using your own Git repository, use the following steps.

- Fork this repository to your own GitHub account.

- Modify the parameters in `config/<version>/**/values.yaml` based on your specific installation requirements. The [official Cloud Pak for Watson AIOps GitOps repository](https://github.com/IBM/cp4waiops-gitops) uses a set of [helm charts](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/) to wrap all Cloud Pak for Watson AIOps configuration YAML manifests in multiple helm templates. With a helm chart, you can customize the Cloud Pak for Watson AIOps installation parameters that are defined in a set of [`values.yaml`](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/#values-files) files. For example, the `values.yaml` for the all-in-one configuration provides a set of parameters with default values that allow the customization of the Cloud Pak for Watson AIOps installation using all-in-one configuration.

- You can also define more `values.yaml` files if needed. These `values.yaml` files along with the original `values.yaml` file can all be applied when you create an Argo CD App to start the Cloud Pak for Watson AIOps installation, either from the UI or command line.

- Follow the installation guide for a specific Cloud Pak for Watson AIOps release that is provided in the [official Cloud Pak for Watson AIOps GitOps repository](https://github.com/IBM/cp4waiops-gitops) to install Cloud Pak for Watson AIOps using GitOps. If you install Cloud Pak for Watson AIOps from the UI, then when you create the Argo CD App, in the Argo CD App form, change the `Repository URL` field to match the URL of your own repository, and set the `Revision` field to match the branch that you are working on. You can also apply the additional `values.yaml` files defined in previous step by adding them in `HELM` > `VALUES FILES` field in the form.

- If you install Cloud Pak for Watson AIOps from the command line using the Argo CD CLI, you can set the repository and revision using argument `--repo` and `--revision`. For example, if you forked the [official Cloud Pak for Watson AIOps GitOps repository](https://github.com/IBM/cp4waiops-gitops) into repository `https://github.com/foo/cp4waiops-gitops`, and work on branch `production`, you would run the following command to create an Argo CD App and start the installation of Cloud Pak for Watson AIOps AI Manager:

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

## Advanced installation

- [Deploy Cloud Pak for Watson AIOps demo environment to multiple clusters](./deploy-cloudpak-to-multiple-clusters.md)
- [Deploy Cloud Pak for Watson AIOps demo environment in one click](./deploy-cloudpak-with-sample-apps.md)
<!-- [Deploy Cloud Pak for Watson AIOps Demo Environment Including Cluster Provisioning](./deploy-ocp-cloudpak-with-gitops.md)-->
