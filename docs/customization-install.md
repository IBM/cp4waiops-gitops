## Customization Install

Making changes to this repository requires a working knowledge of Argo CD administration and configuration. A change entails forking the repository, modifying it, installing the changes on a target cluster to validate them.

## Set up a local environment

1. Fork this repository.

1. Modify the files under config/3.2/cp4waiops according to your needs.

1. Follow the [installation instructions](docs/how-to-deploy-cp4waiops-32.md) to install the Cloud Pak in a target cluster.

1. In the ArgoCD application creation section, change the "repoURL" field to match the URL of your repository, set the "TARGET REVISION" field to match the repository's branch where you are making changes.

1. You can also use a terminal to make the changes to the application, using the Argo CD CLI:

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

    For instance, assuming you cloned this repo into https://github.com/mytest/cp4waiops-gitops, and you wanted to make changes in a branch named `new-feature`, you would run the command like this:

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

Observe whether the created application meets your expectations.
