# Advanced Install for CP4WAIOPS (Cloud Pak for Watson AIOps)

GitOps is a declarative way to implement continuous deployment for cloud native applications. You can use GitOps to create repeatable processes for managing OpenShift Container Platform clusters and applications across multi-cluster Kubernetes environments. GitOps handles and automates complex deployments at a fast pace, saving time during deployment and release cycles.

GitOps is a set of practices that use Git pull requests to manage infrastructure and application configurations. In GitOps, the Git repository is the only source of truth for system and application configuration. This Git repository contains a declarative description of the infrastructure you need in your specified environment and contains an automated process to make your environment match the described state. Also, it contains the entire state of the system so that the trail of changes to the system state are visible and auditable. By using GitOps, you resolve the issues of infrastructure and application configuration sprawl.

This tutorial is mainly for customers who want to have their OWN gitops for CP4WAIOPS and want to host the repo in their own Git Systems.

The major steps of advanced install include the following:

- Fork or copy this repo to the Git Account that you want to use

- Modify the parameters in `config/3.2/cp4waiops/values.yaml` based on your requirement
  - GitOps for CP4WAIOPS is using [Helm Chart](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/) to wrapper all of the YAML templates
  - With Helm Chart, you can define different [`values.yaml`](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/#values-files) for different environments. In this repo, we have another two `values.small.yaml` and `values.large.yaml` for different size clusters, you can also define your own `values.<your own>.yaml` based on your cluster requirement

- Follow the [on-line install](how-to-deploy-cp4waiops-32.md) or [airgap install](how-to-deploy-airgap-32.md) to install the Cloud Pak in a target cluster.
  - It is recommended to follow the [Install CP4WAIOPS Using OpenShift Web Console](how-to-deploy-cp4waiops-32.md#install-cp4waiops-using-openshift-web-console)

  - In the [Install CP4WAIOPS using GitOps](how-to-deploy-cp4waiops-32.md#install-cp4waiops-using-gitops)), change the `repoURL` field to match the URL of your repo, set the `TARGET REVISION` field to match the repo's branch where you are making changes.

  - You can also use a terminal to make the changes to the application, using the ArgoCD CLI:

    ```sh
    argocd app create <app-name> \
            --sync-policy automatic \
            --project default \
            --repo <url-fork-or-clone> \
            --path config/3.2/cp4waiops \
            --revision <branch-in-repo> \
            --dest-namespace cp4waiops \
            --dest-server https://kubernetes.default.svc \
            --helm-set spec.cp4waiops_namespace=cp4waiops \
            --helm-set spec.imageCatalog=icr.io/cpopen/ibm-operator-catalog:latest \
            --helm-set spec.channel=v3.2 \
            --helm-set spec.dockerUsername=cp \
            --helm-set spec.dockerPassword= <entitlement-key> \
            --helm-set spec.storageClass=rook-cephfs \
            --helm-set spec.storageClassLargeBlock=rook-cephfs \
            --helm-set spec.size=small
    ```

    - For example, assuming you cloned this repo into https://github.com/mytest/cp4waiops-gitops, and you wanted to make changes in a branch named `new-feature`, you would run the command like this:

    ```sh
    argocd app create cp4waiops \
            --sync-policy automatic \
            --project default \
            --repo https://github.com/mytest/cp4waiops-gitops \
            --path config/3.2/cp4waiops \
            --revision new-feature \
            --dest-namespace cp4waiops \
            --dest-server https://kubernetes.default.svc \
            --helm-set spec.cp4waiops_namespace=cp4waiops \
            --helm-set spec.imageCatalog=icr.io/cpopen/ibm-operator-catalog:latest \
            --helm-set spec.channel=v3.2 \
            --helm-set spec.dockerUsername=cp \
            --helm-set spec.dockerPassword= <entitlement-key> \
            --helm-set spec.storageClass=rook-cephfs \
            --helm-set spec.storageClassLargeBlock=rook-cephfs \
            --helm-set spec.size=small
    ```
