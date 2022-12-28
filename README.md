# azure-kubernetes-high-availability
Example solution to set up Azure Kubernetes Service &amp; Azure Container Registry for high availability.

Reminder: Issues such as [this one](https://stackoverflow.com/questions/42494853/standard-init-linux-go178-exec-user-process-caused-exec-format-error) may arise if the image is built on a machine of a different OS architecture than the cluster OS architecture.
The CPU architecture of the VM instance Standard_D2plds_v5 is Arm64.
The GitHub hosted runners use x86_64: https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#supported-runners-and-hardware-resources