<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Advanced Install for Customers](#advanced-install-for-customers)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Advanced Install for Customers

The major use cases for the customer use GitOps is that you may want to use Github to trace and audit the changes, the following tutorial is how to fork the repo and use your own GitHub repos to deploy Cloud Pak for Watson AIOps.

The major steps of advanced install include the following:

- Fork this repo to the account that you want to use

- Modify the parameters in `config/3.2/cp4waiops/values.yaml` based on your requirement

- Follow the [installation instructions](docs/how-to-deploy-cp4waiops-32.md) to install the Cloud Pak in a target cluster.

  - In the Argo CD application creation section, change the `repoURL` field to match the URL of your repo, set the `TARGET REVISION` field to match the repo's branch where you are making changes.

  - You can also use a terminal to make the changes to the application, using the Argo CD CLI:

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

- Observe whether the created application meets your expectations.
