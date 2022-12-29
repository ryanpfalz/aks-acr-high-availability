# azure-kubernetes-high-availability

---

| Page Type | Languages              | Key Services                                                       | Tools                      |
| --------- | ---------------------- | ------------------------------------------------------------------ | -------------------------- |
| Sample    | Python <br> PowerShell | Azure Kubernetes Service (AKS) <br> Azure Container Registry (ACR) | Docker <br> GitHub Actions |

---

# Architecting Azure Kubernetes Service and Azure Container Registry for high availability

This sample codebase demonstrates how to set up a highly available microservice architecture using [Azure Kubernetes Service](https://learn.microsoft.com/en-us/azure/aks/intro-kubernetes) (AKS) and [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-intro) (ACR), leveraging [multiple regions and Availability Zones](https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview) to maximize fault tolerance.
<br>
The motivation behind this guide is to serve as a technical example of how to approach business continuity/disaster recovery when using AKS and/or ACR.
<br>
This sample provides a hands-on solution and builds on top of existing approaches documented by Microsoft, namely:

-   [Best practices for business continuity and disaster recovery in Azure Kubernetes Service](https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-multi-region)
-   [High availability for multitier AKS applications](https://learn.microsoft.com/en-us/azure/architecture/guide/aks/aks-high-availability)
-   [Cluster operator and developer best practices to build and manage applications on Azure Kubernetes Service](https://learn.microsoft.com/en-US/azure/aks/best-practices)
-   [Geo-replication in Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-geo-replication)
-   Additionally, a GitHub repository authored by a Microsoft Global Black Belt is listed in the [Additional Resources](#Additional-Resources) section

This codebase uses a basic REST API developed in Python using the [Flask](https://flask.palletsprojects.com/en/2.2.x/#) web framework to illustrate the solution.
<br>
Although the scenario presented in this codebase is simple and contrived, it should be viewed as a foundation for modification and expansion into more complex applications.

## Prerequisites

-   [An Azure Subscription](https://azure.microsoft.com/en-us/free/) - for hosting cloud infrastructure
-   [Az CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) - for deploying Azure infrastructure as code
-   (Optional) [A GitHub Account](https://github.com/join) - for deploying code via GitHub Actions

## Running this sample

### _*Setting Up the Cloud Infrastructure*_

#### App Registration

-   [Register a new application](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)
-   [Create a new client secret](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app#add-a-client-secret) - you will use this if you choose to automate the deployment of the application using GitHub Actions

#### Infrastructure

-   Add the desired resource names in `devops/config/variables.json`
-   Run the scripts `devops/scripts/acr.ps1`, `devops/scripts/aks.ps1` (run once for each cluster), and `devops/scripts/traffic-manager.ps1` locally.
-   This will create the ACR instance + replication, AKS instances (multiple regions), and traffic manager profile + endpoints.

#### GitHub Actions Secrets (for automated deployments)

-   To deploy to Azure using GitHub Actions, credentials are required for connection and configuration. In this example, they will be set as [Actions Secrets](https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28). For each of the below secrets, the secret name and steps on how to populate the secret is provided.

1.  `AZURE_SP_CREDENTIALS`:

    -   A JSON object that looks like the following will need to be populated with 4 values:

    ```
    {
       "clientId": "<GUID>",
       "clientSecret": "<STRING>",
       "subscriptionId": "<GUID>",
       "tenantId": "<GUID>"
    }
    ```

    -   You can find more details on creating this secret [here](https://github.com/marketplace/actions/azure-login#configure-a-service-principal-with-a-secret).
    -   For clientId, run: `az ad sp list --display-name <service principal name> --query '[].[appId][]' --out tsv`
    -   For tenantId, run: `az ad sp show --id <clientID> --query 'appOwnerOrganizationId' --out tsv`
    -   For subscriptionId, run: `az account show --query id --output tsv`
    -   For clientSecret: This is the client secret created alongside the App Registration above

### _*Deploying the Codebase*_

-   _Note: This section will discuss deployment of the codebase via GitHub Actions. If you choose not to deploy via GitHub Actions, you may opt to manually deploy the code by following the automated tasks or with another CI/CD tool - the steps will be the same._

1. Deploy the application code by updating the branch trigger in the `.github/workflows/api-cicd.yml` file to trigger the GitHub Action.

    - The first step in the Action will build a Docker image of the Python REST API and push it to the ACR. The functionality of the application running in the container is described in more detail in the below section.
    - The following steps in the Action run in parallel and configure the AKS clusters to use the newly created container.

## Architecture & Workflow

![AKS High Availability](/docs/diagram.png)
_A diagram visually describing..._

1. Region pairing
2. Application functionality
3. Traffic priority

## Potential Use Cases

## Considerations

-   TODOs: Monitoring & Recovery (e.g., when VMSS goes down but cluster is still up; alerting), networking/security
-   Reminder: Issues such as [this one](https://stackoverflow.com/questions/42494853/standard-init-linux-go178-exec-user-process-caused-exec-format-error) may arise if the image is built on a machine of a different OS architecture than the cluster OS architecture.
-   The CPU architecture of the VM instance Standard_D2plds_v5 is Arm64.
-   The GitHub hosted runners use x86_64: https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#supported-runners-and-hardware-resources

## Additional Resources

-   [AKS HA Demo - _GitHub Repository_](https://github.com/clarenceb/aks-ha-demo)
