<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Deploy CP4WAIOPS with GitOps](#deploy-cp4waiops-with-gitops)
  - [Supported CP4WAIOPS Versions](#supported-cp4waiops-versions)
  - [Tutorial](#tutorial)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# Deploy CP4WAIOPS with GitOps

This repo is about using either use OpenShift GitOps or Kubernetes GitOps model to deploy CP4WAIOPS on a Kubernetes or OpenShift Cluster.

## Supported CP4WAIOPS Versions

- [3.1](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.1.0)
- [3.2](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.2.0)

## Tutorial

Please refer to the following tutorial to decide how you want to deploy your Instana Cluster:

- [3.1: Using OpenShift GitOps](./docs/how-to-deploy-cp4waiops-31.md)
- [3.2: Using OpenShift GitOps](./docs/how-to-deploy-cp4waiops-32.md)

## Customization Install

Making changes to this repository requires a working knowledge of Argo CD administration and configuration. A change entails forking the repository, modifying it, installing the changes on a target cluster to validate them.

Navigate to the [Customization Install](./docs/customization-install.md) page for the details.
