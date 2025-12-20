# Azure-Cloud-Technology

## Description

This is a simple web page named Evershop which is deployed in Azure Cloud environment. Evershop uses PostgreSQL as its database to store users' and products' information.

## Architecture

![Azure architecture with ingress](Azure_cloud_technology.png)

In this Azure cloud project, the user can access the webpage through public IP address using Ingress controller. AKS Load Balancer ultilizes ingress controller to map the service to either / or /app1.


## Deploying

Before deploying, a resource group, AKS cluster and virtual machine are required in the Azure cloud environment. 

The deployment can be run with kubectl:

```
kubectl apply -f ./kube-manifests
```

You can check the pods by running this command:
```
kubectl get pods
```

You can check the pods by running this command:
```
kubectl get sv
```

You can check the deployments by running this command:
```
kubectl get deployments
```

You can check the persistent volumne by running this command:
```
kubectl get pvc
```

You can check the ingress by running this command:
```
kubectl get ingress
```

The deployment can be deleted with kubectl:
```
kubectl delete -f ./kube-manifests
```