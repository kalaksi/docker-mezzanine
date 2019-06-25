
## Repositories
- [Docker Hub repository](https://registry.hub.docker.com/u/kalaksi/mezzanine/)
- [GitHub repository](https://github.com/kalaksi/docker-mezzanine)

## Why use this container?
**Simply put, this container has been written with simplicity and security in mind.**

Surprisingly, _many_ community containers run unnecessarily with root privileges by default and don't provide help for dropping unneeded CAPabilities either.
On top of that, overly complex shell scripts, monolithic designs and unofficial base images make it harder to verify the source among other issues.

To remedy the situation, these images have been written with security and simplicity in mind.

|Requirement              |Status|Details|
|-------------------------|:----:|-------|
|Don't run as root        |✅    | Never run as root unless necessary.|
|Official base image      |✅    | |
|Drop extra CAPabilities  |✅    | See ```docker-compose.yml``` |
|No default passwords     |—     | (Not applicable) No static default passwords. That would make the container insecure by default. |
|Support secrets-files    |—     | (Not applicable) Support providing e.g. passwords via files instead of environment variables. |
|Handle signals properly  |✅    | |
|Simple Dockerfile        |✅    | Keep everything in the Dockerfile if reasonable.|
|Versioned tags           |✅    | Offer versioned tags for stability.|

## Running this container
This container only contains Mezzanine and Gunicorn and does not run a HTTP server (which is how things should be). However, this container generates working Nginx configuration and can easily be used with official Nginx container without additional steps.  
The ```docker-compose.yml``` in the source repository contains a complete example.

By default, this container runs the Gunicorn server which expects to find an existing Mezzanine project.
You only need to define the ```MEZZANINE_PROJECT``` environment variable which is the projects (directory's) name.
**See below for more information on how to start a new project.**

## Configuration
This container does not currently offer any environment variables for configuring the project(s) themselves. Unfortunately, configuring the project is usually a complex task and there are many important configuration options to check. Containers that offer just a limited set (e.g. for only database settings) only give a false sense of simplicity!  

It's best you get familiar with configuring Django/Mezzanine projects and just modify the ```local_settings.py``` yourself.

#### Creating a new Mezzanine project
This is a quick guide for creating a new project. For more details, see the Mezzanine documentation: http://mezzanine.jupo.org/docs/overview.html#installation  
  
Execute a shell inside the container (or run the necessary commands from outside). This can be achieved with e.g. ```docker-compose run mezzanine sh``` which will also ensure the necessary volumes are mounted.  

Then do the usual steps:
1. Create a new project and descend to the directory with: ```mezzanine-project my_new_project && cd my_new_project```
2. Configure the project etc. by modifying file ```my_new_project/local_settings.py``` (or do the modifications from outside this container).
3. Create database with: ```python3 manage.py createdb --noinput```
4. Collect the static files from projects for serving: ```python3 manage.py collectstatic --noinput```

#### Tweaking the Nginx configuration template
The template file resides in ```/etc/nginx/mezzanine.conf.tpl```. Instances of ```MEZZANINE_PROJECT``` will be replaced with the project's name and the actual configuration file placed in ```/etc/nginx/conf.d/mezzanine_my_new_project.conf```, where "my_new_project" is of course the project's name.  
  
To alter the template, you only need to get it replaced one way or another. You could bind-mount something over it or mount a volume over the whole ```/etc/nginx``` directory. See ```docker-compose.yml``` for an example.

## Supported tags
See the ```Tags``` tab on Docker Hub for specifics. Basically you have:
- The default ```latest``` tag that always has the latest changes.
- Minor versioned tags (follow Semantic Versioning), e.g. ```1.1``` which would follow branch ```1.1.x``` on GitHub.

## Development

### Contributing
See the repository on <https://github.com/kalaksi/docker-mezzanine>.
All kinds of contributions are welcome!

## License
View [license information](https://github.com/kalaksi/docker-mezzanine/blob/master/LICENSE) for the software contained in this image.
As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

