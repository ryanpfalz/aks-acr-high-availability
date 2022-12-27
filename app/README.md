# Python Flask REST API

Example Project on how to develop a REST API with Flask and Python + MongoDB backend, logging, payment processor,
authentication, and Docker.

Resources:

- https://github.com/bbachi/python-flask-restapi
- https://medium.com/bb-tutorials-and-thoughts/how-to-run-and-deploy-python-rest-api-on-azure-app-services-5d80dbcd370f
- https://www.quora.com/Are-the-Python-frameworks-Flask-or-Bottle-scalable (Flask is best run in Docker and scaled out
  to handle traffic)
- https://www.freecodecamp.org/news/how-to-dockerize-a-flask-app/

- Note that bson may need to be locally installed prior to pymongo

MongoDB design

```
{
    item_list: []
}
```

To dockerize:

- Start daemon with: ```sudo dockerd```
- Images: ```sudo docker images```
- Build (after CDing into dir): ```sudo docker build --tag <image_name> .```
- Run container (interactive): ```sudo docker run -i -t -p 8080:8080 <image_name>```
- Containers currently running: ```docker ps```
- Remove image: ```docker rmi -f <image_name_or_id>```

Push to GitLab:
- Login: ```sudo docker login registry.gitlab.com```
- Build: ```sudo docker build -t registry.gitlab.com/ryanpfalz/sandbox .```
- Push: ```sudo docker push registry.gitlab.com/ryanpfalz/sandbox```
- Images can be found in ```https://gitlab.com/ryanpfalz/sandbox/container_registry```

Gitlab Registry Image to Azure App Service
- https://steventang.net/blog/2019/azure-gitlab
  - Once a Dockerfile has been created for the desired project, browse to the chosen repo and follow instructions under Packages -> Container Registry.
  - If two-factor-authentication is enabled, a Personal Access Token with api scope is required. Once the image has been pushed, it should show up once the page is refreshed.
  - Next, browse to Settings -> Repository. Create a deploy token with read_registry scope and note down the password.
  - Create an App Service Web App. beside Publish, select Docker Container.
  - Proceed to the Docker tab. Under Image Source, select Private Registry. If an app has already been created, change these settings under the ‘Containers settings’ page instead.
  - The server URL should be https://registry.gitlab.com.
  - The username/password fields should reflect the username/password of the deploy token.
  - The image and tag field should be something the lines of registry.gitlab.com/<username>/<repo>:latest, the former part of which can be obtained by clicking the copy icon on the Container Registry page on Gitlab.
- IMPORTANT: In app service configuration, set WEBSITES_PORT to 8080 (or whatever was exposed in Dockerfile)
- Optional: Set WEBSITES_CONTAINER_START_TIME_LIMIT to a value like 600

Terraform:
- https://k21academy.com/terraform-iac/terraform-cheat-sheet/
- cd to Terraform setup directory
- ```terraform init```
- ```tarraform get```
- ```terraform import``` (import  from .sh or .ps1 file)
  - after importing, run local ps script: ```powershell -File "/path/to/powershell/powershell_file.ps1"```
- ```terraform plan```
- ```terraform apply```
- If deleting: same story, except to delete individual resources, they all need to be imported after init (NOT the resource group or location itself, these values should be stored as locals)
    instead of apply, run 'destroy'
