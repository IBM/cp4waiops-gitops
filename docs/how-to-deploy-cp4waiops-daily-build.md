# Deploy CP4WAIOps daily build using GitOps

## 
The procedure for deploying CP4WAIOps with daily build is very similar compare to deploying with GAed build, you can follow the [Deploy Cloud Pak for Watson AIOps using GitOps guide](https://github.com/IBM/cp4waiops-gitops/blob/docs/docs/how-to-deploy-cp4waiops.md) to deploy CP4WAIOps with daily build, the only differences are in 3 places.
- First, in the [update the OCP global pull secret instruction here](https://github.com/IBM/cp4waiops-gitops/blob/docs/docs/how-to-deploy-cp4waiops.md#update-the-global-pull-secret-using-the-openshift-console), need to add build repository credential. you can find the [build repository info here](https://ibm.box.com/s/xn3epa3a11jlryo0t1mwt0xxkmwv7o70)
   - "Registry Server Address": [build repository] 
   - "Username": [Your Email address]
   - "Password": paste the api token of the account above
   - "Email": any email, valid or not, will work. This fields is mostly a hint to other people who may see the entry in the configuration  
  
- Second, under [Install shared components](https://github.com/IBM/cp4waiops-gitops/blob/docs/docs/how-to-deploy-cp4waiops.md#install-shared-components), need to use build catalog image instead of GA catalog for `spec.imageCatalog`. please check daily build [instruction here](https://ibm.box.com/s/xn3epa3a11jlryo0t1mwt0xxkmwv7o70) to obtain build catalog image link. For Cli deployment, need to replace `spec.imageCatalog` in the Cli command under [Install shared components (Cli)](https://github.com/IBM/cp4waiops-gitops/blob/docs/docs/how-to-deploy-cp4waiops.md#install-shared-components-cli)
  
- Third, under [Install AI Manager](https://github.com/IBM/cp4waiops-gitops/blob/docs/docs/how-to-deploy-cp4waiops.md#install-ai-manager), need to use daily build dev channel instead, for `spec.aiManager.channel` . please check daily build [instruction here](https://ibm.box.com/s/xn3epa3a11jlryo0t1mwt0xxkmwv7o70) to obtain daily build dev channel name. for Cli deployment, need to replace `spec.aiManager.channel` in the Cli command under [Install AI Manager (Cli)](https://github.com/IBM/cp4waiops-gitops/blob/docs/docs/how-to-deploy-cp4waiops.md#install-ai-manager-cli)

