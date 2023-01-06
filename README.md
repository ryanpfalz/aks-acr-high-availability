# azure-kubernetes-high-availability

---

| Page Type | Languages              | Key Services                                                       | Tools                      |
| --------- | ---------------------- | ------------------------------------------------------------------ | -------------------------- |
| Sample    | Python <br> PowerShell | Azure Kubernetes Service (AKS) <br> Azure Container Registry (ACR) | Docker <br> GitHub Actions |

---

# Architecting Azure Kubernetes Service and Azure Container Registry for high availability

#### Introduction

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
Although the scenario presented in this codebase is simple and contrived, it should be viewed as a foundation for modification and expansion into more complex applications. This example focuses on a foundational setup and is not intended for production use.

#### Defining Disaster Recovery, Business Continuity, and High Availability

Disaster Recovery (DR) and Business Continuity (BC) are two different concepts designed to ensure that organizations are prepared for unplanned outages and disruptions. Disaster Recovery focuses on restoring data and systems quickly after an unexpected event, while Business Continuity plans for the prevention, detection, and mitigation of any potential disruption. The main goal of DR is to recover lost data and systems quickly and efficiently, while BC focuses on minimizing the impact of an outage and ensuring that the organization can continue its operations as quickly as possible.

High Availability (HA) is a type of system architecture designed to ensure that a system remains available and functioning in the event of an outage or disruption. HA focuses on preventing outages and disruptions, by providing redundancy and a high level of scalability. HA systems are typically composed of multiple redundant components that can be swapped out in case of an outage.

## Prerequisites

-   [An Azure Subscription](https://azure.microsoft.com/en-us/free/) - for hosting cloud infrastructure
-   [Az CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) - for deploying Azure infrastructure as code
-   [Python](https://www.python.org/downloads/) - for Python development
-   (Optional) [A GitHub Account](https://github.com/join) - for deploying code via GitHub Actions

## Running this sample

### _*Setting Up the Cloud Infrastructure*_

#### App Registration

-   [Register a new application](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)
-   [Create a new client secret](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app#add-a-client-secret) - you will use this if you choose to automate the deployment of the application using GitHub Actions

#### Infrastructure

-   Add the desired resource names in `devops/config/variables.json`
-   Run the scripts `devops/scripts/acr.ps1`, `devops/scripts/aks.ps1` (run once for each cluster, set the `$clusterParam` value to either 'blue' or 'green'), and `devops/scripts/front-door.ps1` locally.
-   This will create the ACR instance + replication, AKS instances (multiple regions), and Azure Front Door with backends.

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
_A diagram visually describing the flow of code from local development to GitHub to Azure, and the way the components communicate in Azure. This diagram is based on the best practice traffic routing diagram that can be found [here](https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-multi-region#use-azure-traffic-manager-to-route-traffic); however, this guide uses Azure Front Door instead of Traffic Manager._

This architecture includes the following components and design decisions for redundancy:

1. When designing a multi-region AKS setup, it is important to [pair the regions](https://learn.microsoft.com/en-us/azure/reliability/cross-region-replication-azure) in a way that ensures physical isolation, meets data residency requirements, and avoids potential downtime related to planned regional updates. This sample uses the East US 2 and Central US regions, which is a [recommended pairing](https://learn.microsoft.com/en-us/azure/reliability/cross-region-replication-azure#azure-cross-region-replication-pairings-for-all-geographies) for North America.
2. This solution enables zone redundancy via Availability Zones in [AKS](https://learn.microsoft.com/en-us/azure/aks/availability-zones) and [ACR](https://learn.microsoft.com/en-us/azure/container-registry/zone-redundancy), which is a recommended strategy for improving availability of the application in the event of failure within a single zone. Choose regions that [support zone redundancy](https://learn.microsoft.com/en-us/azure/container-registry/zone-redundancy#regional-support). Additionally, this solution demonstrates a multi-region deployment, which is designed to mitigate outages at a regional level. Please note there are some [Availability Zone limitations](https://learn.microsoft.com/en-us/azure/aks/availability-zones#limitations-and-region-availability).
3. Use [geo replication with ACR](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-geo-replication#benefits-of-geo-replication) to enhance resilience. This requires that the ACR instance be on the Premium SKU. There is no additional overhead in maintaining the replica - you only need to push to and pull from a single registry URL.
4. Use Azure Front Door to "connect" your regions and direct traffic to your clusters - this guide routes traffic using the default [weighted routing method](https://learn.microsoft.com/en-us/azure/frontdoor/routing-methods#weighted-traffic-routing-method), but other strategies could be to use a [priority-based](https://learn.microsoft.com/en-us/azure/frontdoor/routing-methods#priority-based-traffic-routing) or [lowest-latency based](https://learn.microsoft.com/en-us/azure/frontdoor/routing-methods#lowest-latencies-based-traffic-routing) routing method.

In this codebase, the application that runs on the clusters is a REST API written in Python that simply returns the hostname and IP address of the cluster it's running on. To invoke the REST API, perform an `HTTP GET` request on the following URL: `<your-frontdoor-URL>/default`. To retrieve your Front Door URL, you may view the overview blade of the resource in the Azure Portal, or you may run the command `az network front-door frontend-endpoint list  --front-door-name <frontdoor-name>  --resource-group <resource-group-name> --query '[].hostName' -o tsv`.

## Considerations & Next Steps

_Since this codebase does not yet include the deep technical complexities of a complete production instantiation of a highly available architecture, a handful of topics have not yet been addressed, but are described below. This codebase should be viewed as a work-in-progress, and efforts toward implementing the below may be made as future enhancements._

#### Complexities of achieving high availability

One could view there as being multiple tiers in achieving high availability with AKS, with each tier introducing both higher availability as well as additional operational complexities. This codebase introduces the concepts listed in Tier 3 (and also includes both Tier 1 & 2) below. Depending on your availability requirements, you may not need to explore higher-tier setups.

-   Tier 1: A standard deployment of AKS offers a level of high availability out-of-the-box with features like pod auto-scaling, self-healing, load balancing, upgrade management, and scheduling. This tier does not include any additional availability mechanisms.
-   Tier 2: The enablement of availability zones is a simple yet effective way of improving availability with the check of a box. This solution is more costly but reduces risk of downtime due to an outage.
-   Tier 3: The introduction of a failover region (as demonstrated in this guide) further mitigates the risk of downtime due to an outage, and can improve performance for consumers. This approach is the most costly and increases the operational overhead of the solution.

As an organization, the most efficient/appropriate balance of downtime risk vs. cost needs to be determined, which will help you in choosing which Tier to deploy.

#### Additional pillars in high availability:

-   Constant [monitoring](https://learn.microsoft.com/en-us/azure/architecture/guide/aks/aks-high-availability#monitoring) of the cluster via liveness, readiness, and startup probes ensures that the workload is healthy.

    -   If the workload is detected to be unhealthy, mechanisms for triggering an automated alert and recovery process (see below) should be in place.
    -   Tools like [Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-analyze#analyze-nodes-controllers-and-container-health) can be used to diagnose issues.

-   As an extension of monitoring, [recovering](https://learn.microsoft.com/en-us/azure/architecture/guide/aks/aks-high-availability#recovery) the system when a monitoring process detects an issue is a critical pillar of maintaining high availability.

    -   Discovery, isolation, and redirection of traffic away from the unhealthy process is the first step to fixing the system.
    -   The unhealthy component then needs to be repaired.
    -   Finally, the newly repaired component should be restored to the system.

#### Additional best practices for a production scenario:

-   Networking

    -   To enable communication between clusters, place the clusters in VNETs and [peer](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) the VNETs together.
    -   Depending on things like application type and latency tolerance, network topology needs to be considered, as does whether the application components are spread across multiple regions, or if the entire application is deployed in each region. See more [here](https://learn.microsoft.com/en-us/azure/architecture/guide/aks/aks-high-availability#ha-and-dr). This example deploys the entire solution into each region.

-   Security

    -   A deep and separate subject in itself - ensuring [cluster security and access](https://learn.microsoft.com/en-us/azure/aks/concepts-security#cluster-security) meets your organizational requirements is critical for a production setup. This sample uses public IPs to access the clusters.

-   State & Storage

    -   [Avoid retaining state inside the container](https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-multi-region#remove-service-state-from-inside-containers) - instead, use a storage service that supports replication, like [Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/introduction) or [Azure SQL DB](https://learn.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview?view=azuresql).
    -   [Storage synchronization](https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-multi-region#create-a-storage-migration-plan) between regions can be achieved by either an [application-based](https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-multi-region#application-based-asynchronous-replication) approach (where the application itself replicates storage requests), or by an [infrastructure-based](https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-multi-region#infrastructure-based-asynchronous-replication) approach (where a common storage point is used which applications write to).

#### Troubleshooting & Pitfalls:

-   A common error when deploying containers to Kubernetes is the CrashLoopBackOff error. This error is the result of when a pod fails to start, and Kubernetes repeatedly tries and fails to restart the pod. A place to start debugging is to run `kubectl logs -n <namespace-name> -p <pod-name>`, which may reveal a more detailed trace of the root cause.
-   Issues like [this one](https://stackoverflow.com/questions/42494853/standard-init-linux-go178-exec-user-process-caused-exec-format-error) may arise when a Docker image is built on a machine of a different OS architecture than the cluster instance OS. Ensure that the OS architecture of the Azure instances you deploy use the same OS architecture as your build agent. In this example, the AKS clusters and [GitHub runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#supported-runners-and-hardware-resources) have an x86_64 architecture.

## Potential Use Cases

-   There are many practical use cases for ensuring high availability of an application, some of which include keeping critical systems online when natural disasters/outages occur, ensuring end users experience low latency, and ensuring that you are delivering on your SLA to your customers.
-   Having the technical components in place is critical for realizing a business' functional disaster recovery plan.

## Additional Resources

-   [AKS HA Demo - _GitHub Repository_](https://github.com/clarenceb/aks-ha-demo)
