# Python Flask REST API

Example Project on how to develop a REST API with Flask and Python + MongoDB backend, logging, payment processor,
authentication, and Docker.

Resources:

-   https://github.com/bbachi/python-flask-restapi
-   https://www.freecodecamp.org/news/how-to-dockerize-a-flask-app/

To dockerize:

-   Start daemon with: `sudo dockerd`
-   Images: `sudo docker images`
-   Build (after CDing into dir): `sudo docker build --tag <image_name> .`
-   Run container (interactive): `sudo docker run -i -t -p 8080:8080 <image_name>`
-   Containers currently running: `docker ps`
-   Remove image: `docker rmi -f <image_name_or_id>`
