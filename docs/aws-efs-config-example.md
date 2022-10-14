<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [AWS EFS Storage Configuration Example](#aws-efs-storage-configuration-example)
  - [Prerequisite](#prerequisite)
  - [Update default security group to enable EFS access](#update-default-security-group-to-enable-efs-access)
  - [Creating EFS Storage](#creating-efs-storage)
  - [Deploying EFS provisioner in the AWS cluster](#deploying-efs-provisioner-in-the-aws-cluster)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# AWS EFS Storage Configuration Example

## Prerequisite

- Refer to the [AWS EFS guide](https://docs.aws.amazon.com/efs/latest/ug/getting-started.html) for details.
- EFS storage configuration requires the following cluster configuration data:
  - cluster node VPC ID
  ![](images/aws-efs-get-vpc-id.png)
  - VPC security group IDs for the master node and worker nodes as well as the default security group
  ![](images/aws-efs-get-security-group-ids.png)
## Update default security group to enable EFS access
- Edit the cluster default security group inbound rules
  - Add NFS rule for master node security group
  - Add NFS rule for worker node security group
  ![](images/aws-efs-edit-sg-add-inbound-nfs-rules.png)
## Creating EFS Storage
- From the AWS UI console, go to Services->EFS
- Create file system
  - Select Customize
  ![](images/aws-efs-create-efs-customize.png)
  - From the Virtual Private Cloud (VPC) panel, select the VPC associated with the cluster master node.
  ![](images/aws-efs-create-efs-select-vpc.png)
  - Use default settings for the other options

## Deploying EFS provisioner in the AWS cluster
- Log in to the AWS cluster
- Create a script called efs-helm.sh with the following code:  
```bash
FSID=<EFS File system ID>  # Get from Amazon EFS File systems list
REGION=<EFS Region>        # for example, use `us-east-2` for region us-east-2a/b/c

helm install efs-provisioner \
    --namespace default \
    --set  efsProvisioner.efsFileSystemId=${FSID} \
    --set efsProvisioner.awsRegion=${REGION} \
    efs-provisioner-0.13.2.tgz
```
- Run efs-helm.sh script to deploy the efs provisioner
- Update the efs storage class as default storage
  - remove the current default storage class from gp2
  - edit sc `aws-efs` and add the following settings in the YAML to set it as the default storage class.
```yaml
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
```
