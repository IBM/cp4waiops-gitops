<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Creating a Multi-arch Docker Registry](#creating-a-multi-arch-docker-registry)
  - [Prerequisites](#prerequisites)
  - [Procedure](#procedure)
    - [Install Httpd Tools](#install-httpd-tools)
    - [Create Folders for Docker Registry](#create-folders-for-docker-registry)
    - [Provide Certificate for Docker Registry](#provide-certificate-for-docker-registry)
    - [Generate User Name and Password for Docker Registry](#generate-user-name-and-password-for-docker-registry)
    - [Create docker-registry Container to Host Your Registry](#create-docker-registry-container-to-host-your-registry)
    - [Open Required Ports for Docker Registry](#open-required-ports-for-docker-registry)
    - [Add Self-signed Certificate to Your List of Trusted Certificates](#add-self-signed-certificate-to-your-list-of-trusted-certificates)
    - [Confirm Docker Registry is Available](#confirm-docker-registry-is-available)
  - [Access Docker Registry](#access-docker-registry)
    - [Generate base64-encoded User Name and Password or Token for Your Mirror Registry](#generate-base64-encoded-user-name-and-password-or-token-for-your-mirror-registry)
    - [Prepare Pullsecret Content](#prepare-pullsecret-content)
    - [Create Imagepullsecret](#create-imagepullsecret)
    - [Handle Cert for Accessing Docker Registry](#handle-cert-for-accessing-docker-registry)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Creating a Multi-arch Docker Registry

## Prerequisites

* You have a Red Hat Enterprise Linux (RHEL) server on your network to use as the registry host.

* The registry host can access the internet.

## Procedure
### Install Httpd Tools

```
yum -y install docker httpd-tools
```

### Create Folders for Docker Registry

```
mkdir -p /opt/registry/{auth,certs,data}
```

### Provide Certificate for Docker Registry

If you do not have an existing, trusted certificate authority, you can generate a self-signed certificate:

```
cd /opt/registry/certs
openssl req -newkey rsa:4096 -nodes -sha256 -keyout domain.key -x509 -days 365 -out domain.crt
```

At the prompts, provide the required values for the certificate:

```
Country Name (2 letter code)	
Specify the two-letter ISO country code for your location. See the ISO 3166 country codes standard.

State or Province Name (full name)	
Enter the full name of your state or province.

Locality Name (eg, city)	
Enter the name of your city.

Organization Name (eg, company)	
Enter your company name.

Organizational Unit Name (eg, section)	
Enter your department name.

Common Name (eg, your name or your server’s hostname)	
Enter the host name for the registry host. Ensure that your hostname is in DNS and that it resolves to the expected IP address.

Email Address	
Enter your email address. For more information, see the req description in the OpenSSL documentation.
```

**Note**: make sure enter the `hostname` for the common name , that could be resolved to the expect IP address when login docker reigstry

### Generate User Name and Password for Docker Registry

```
htpasswd -bBc /opt/registry/auth/htpasswd <user_name> <password> 
```
**Note:** you will use this `user_name` `password` to login the docker registry

### Create docker-registry Container to Host Your Registry

```
docker run --name mirror-registry -p <local_registry_host_port>:5000 \
     -v /opt/registry/data:/var/lib/registry:z \
     -v /opt/registry/auth:/auth:z \
     -e "REGISTRY_AUTH=htpasswd" \
     -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
     -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
     -v /opt/registry/certs:/certs:z \
     -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
     -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
     -e REGISTRY_COMPATIBILITY_SCHEMA1_ENABLED=true \
     -d docker.io/library/registry:2
```
**Note:** For `local_registry_host_port`, specify the port that your docker registry uses to serve content

### Open Required Ports for Docker Registry
 
```
# firewall-cmd --add-port=<local_registry_host_port>/tcp --zone=internal --permanent 
# firewall-cmd --add-port=<local_registry_host_port>/tcp --zone=public   --permanent 
# firewall-cmd --reload
```

### Add Self-signed Certificate to Your List of Trusted Certificates

```
cp /opt/registry/certs/domain.crt /etc/pki/ca-trust/source/anchors/
# update-ca-trust
```

### Confirm Docker Registry is Available

```
curl -u <user_name>:<password> -k https://<local_registry_host_name>:<local_registry_host_port>/v2/_catalog 

{"repositories":[]}
```

**Note:**
- For `user_name` and `password` , specify the user name and password for your registry.
- For `local_registry_host_name`, specify the registry domain name that you specified in your certificate, such as `registry.example.com`
- For `local_registry_host_port`, specify the port that your docker registry uses to serve content

## Access Docker Registry

### Generate base64-encoded User Name and Password or Token for Your Mirror Registry

```
# echo -n '<user_name>:<password>' | base64 -w0

YWRtaW46YWRtaW4=
```

**Note:** For `user_name` and `password`, specify the user name and password that you configured for your registry

### Prepare Pullsecret Content

```console
# cat config.json
{
  "auths": {
    "<local_registry_host_name>:<local_registry_host_port>": {
      "auth": "YWRtaW46YWRtaW4="
    }
  }
}
```

**Note:**
- For `local_registry_host_name`, specify the registry domain name that you specified in your certificate.
- For `local_registry_host_port`, specify the port that your docker registry uses to serve content.
- For `credentials`, specify the base64-encoded user name and password for the docker registry that you generated.
	
### Create Imagepullsecret

```
kubectl create secret generic cp4mcm-pull-secret \
  --from-file=.dockerconfigjson=<path>/config.json \
  --type=kubernetes.io/dockerconfigjson 
```

**Note:** You need fill in the `config.json` path here

### Handle Cert for Accessing Docker Registry

- Pure kuberentes
  - Copy the domain.crt file to `/etc/docker/certs.d/<local_registry_host_name>:<local_registry_host_port>/ca.crt` on every kubernetes node . You do not need to restart Docker
- OCP 4
  - Copy the `domain.crt` to cluster and rename it to `ca.crt`
  - Create configmap and patch to use the cert
	  
```
# oc create configmap registry-config --from-file=${MIRROR_ADDR_HOSTNAME}..${local_registry_host_port}=$path/ca.crt -n openshift-config
	
# oc patch image.config.openshift.io/cluster --patch '{"spec":{"additionalTrustedCA":{"name":"registry-config"}}}' --type=merge
```
