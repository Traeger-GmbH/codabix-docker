# CoDaBix Docker

This is the repository containing CoDaBix Docker images.

## Running the latest version

For running the latest image use the following commands.

### __Interactive__ mode

```
docker run -it -p 8181:8181 traeger/codabix:latest
````

### __Detached__ mode

To run the container in detached mode (with docker run parameter `-d` instead of `-it`) you have to pass the additional parameter `--runAsService` to enable daemon mode:

```
docker run -d -p 8181:8181 traeger/codabix:latest --runAsService
````

### Persistence

Per default the directory `/home/codabix/data` will be used as project directory where CoDaBix will store its data.
To persist this data independent of the CoDaBix container you can either use a docker volume or bind this directory to the filesystem of the host. 

#### Using a volume

1. Create a new volume that will hold the application data:

```
docker volume create codabix-data
```

2. Mount the volume under the project directory path during the start of the CoDaBix container:

```
docker run -d p 8181:8181 -v codabix-data:/home/codabix/data traeger/codabix:latest --runAsService
```

#### Bind to the host's filesystem

Instead of passing the name of a docker volume simply pass the path of the hosts directory as first part of the `-v` option.
The CoDaBix process inside the container is run by the user `codabix` with user id 999 and group id 999. So you have to map the user (using the flag `-u 999`) to match the respective permissions on your file system.

```
docker run -d p 8181:8181 -u 999 -v /path/to/hosts/directory:/home/codabix/data traeger/codabix:latest --runAsService
```

## Using docker-compose

If you want to use docker-compose to run the application create a new file `docker-compose.yml` on your filesystem and copy and paste the following content.

``` docker-compose.yml
version: "2"
services:
  codabix:
    image: traeger/codabix:latest
    ports:
      - "8181:8181"
    volumes:
      - "codabix-data:/home/codabix/data"
    environment:
      CODABIX_ADMIN_PASSWORD: admin
      CODABIX_PROJECT_NAME: My CoDaBix project
    command:  --runAsService
volumes:
  codabix-data:

```

### Running the docker-compose service

To start the service defined by the `docker-compose.yml` navigate into the directory where the file is located and run the following command:

```
docker-compose up
```

For detached mode pass the flag `-d`:

```
docker-compose up -d
```

## Stopping the service

### Persistent
 
Executing the following command will remove the container and its corresponding resources but persist the volume that contains the data created by CoDaBix.

```
docker-compose down
```

#### Cleaning up

If you also want to remove the volume pass the `-v` option to the command:

```
docker-compose down -v
```

## CoDaBix settings

### Default settings

* Default project directory: `/home/codabix/data`
* Default admin password: `admin`
* Default project name: `data`

### Overriding the default settings

You can override the default settings by using environment variables passed with `--env` to the container on start.

* Project directory: `CODABIX_PROJECT_DIR`
* Admin password: `CODABIX_ADMIN_PASSWORD`
* Project name: `CODABIX_PROJECT_NAME`

For overriding e.g. the admin password with the value `MySuperComplexPassword` the container is run like follows:

```
docker run -d -p 8181:8181 --env CODABIX_ADMIN_PASSWORD=MySuperComplexPassword traeger/codabix:latest
```

> NOTE: When running the CoDaBix image with persisted data (already existing application data from a previous run) overriding the admin password or the project name will have no effect.
