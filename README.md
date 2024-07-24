# Codabix Docker

We provide Codabix Docker images via the following Github packages repository:<br>
`ghcr.io/traeger-gmbh/codabix`

You can find the images and documentation under [https://github.com/Traeger-GmbH/codabix-docker/pkgs/container/codabix](https://github.com/Traeger-GmbH/codabix-docker/pkgs/container/codabix).

**Note:** The repository on Docker Hub is maintained for compatibility reasons only; we do not guarantee that there will be all versions/tags available forever.

## Running the latest version

For running the latest image use the following commands.

### __Interactive__ mode

```
docker run -it -p 8181:8181 ghcr.io/traeger-gmbh/codabix:latest
```

### __Detached__ mode

To run the container in detached mode (with docker run parameter `-d` instead of `-it`) you have to pass the additional parameter `--run-as-service` to enable daemon mode:

```
docker run -d -p 8181:8181 ghcr.io/traeger-gmbh/codabix:latest --run-as-service
```

### Persistence

Per default the directory `/home/codabix/data` will be used as project directory where Codabix will store its data.
To persist this data independent of the Codabix container you can either use a docker volume or bind this directory to the filesystem of the host.

#### Using a volume

1. Create a new volume that will hold the application data:

```
docker volume create codabix-data
```

2. Mount the volume under the project directory path during the start of the Codabix container:

```
docker run -d -p 8181:8181 -v codabix-data:/home/codabix/data ghcr.io/traeger-gmbh/codabix:latest --run-as-service
```

#### Bind to the host's filesystem

Instead of passing the name of a docker volume simply pass the path of the hosts directory as first part of the `-v` option.
The Codabix process inside the container is run by the user `codabix` with user id 999 and group id 999. So you have to map the user (using the flag `-u 999`) to match the respective permissions on your file system.

```
docker run -d -p 8181:8181 -u 999 -v /path/to/hosts/directory:/home/codabix/data ghcr.io/traeger-gmbh/codabix:latest --run-as-service
```

## Using docker-compose

If you want to use docker-compose to run the application create a new file `docker-compose.yml` on your filesystem and copy and paste the following content.

``` docker-compose.yml
version: "2"
services:
  codabix:
    image: ghcr.io/traeger-gmbh/codabix:latest
    ports:
      - "8181:8181"
    volumes:
      - "codabix-data:/home/codabix/data"
    environment:
      CODABIX_ADMIN_PASSWORD: StrongAdminPassword
      CODABIX_PROJECT_NAME: My Codabix project
    command:  --run-as-service
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

### Stopping the service

#### Persistent
 
Executing the following command will remove the container and its corresponding resources but persist the volume that contains the data created by Codabix.

```
docker-compose down
```

#### Cleaning up

If you also want to remove the volume pass the `-v` option to the command:

```
docker-compose down -v
```

## Restoring from a backup file

To restore the configuration from a Codabix backup file the file has to be accessible inside the container (e.g. by mounting its containing directory). An environment variable `CODABIX_RESTORE_FILE` is used to pass its path to the startup script.

The following command assumes that the backup file is located on the host's filesystem under the path `/home/SomeUser/codabix/restore-file.cbx`.

```
docker run -d -p 8181:8181 -v /home/SomeUser/codabix/restore-file.cbx:/home/codabix/restore-file.cbx --env CODABIX_RESTORE_FILE=/home/codabix/restore-file.cbx ghcr.io/traeger-gmbh/codabix:latest --run-as-service
```

## Enable access to peripherals

The following section describes the setup that is necessary to access hardware peripherals of the host system (e.g. i2C, USB, serial ports,...).

* Mount the `/dev` directory as volume by passing the command line option `-v /dev:/dev`
* Usually you need root privileges to access the hardware peripherals. As the default user that runs Codabix inside the docker container does not have these kind of privileges it is necessary to override this by `-u root`
* In addition to that a container is not allowed to access any devices of the. So you have to explicitly give permission to that by passing `--privileged`

```
docker run -d -p 8181:8181 -u root -v /dev:/dev -v /path/to/hosts/directory:/home/codabix/data ghcr.io/traeger-gmbh/codabix:latest --run-as-service
```

**Please note**:
As this container now is executed as `root` user the files created on the host's filesystem will be owned by the `root` user and you need `root` or `sudo` privileges to remove or change them.

Example when using __docker-compose__:

``` docker-compose.yml
version: "2"
services:
  codabix:
    image: ghcr.io/traeger-gmbh/codabix:latest
    ports:
      - "8181:8181"
    volumes:
      - "codabix-data:/home/codabix/data"
      - "/dev:/dev"
    environment:
      CODABIX_ADMIN_PASSWORD: StrongAdminPassword
      CODABIX_PROJECT_NAME: My Codabix project
    command:  --run-as-service
    user: root
    privileged: true
volumes:
  codabix-data:
```

## Codabix settings

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
docker run -d -p 8181:8181 --env CODABIX_ADMIN_PASSWORD=MySuperComplexPassword ghcr.io/traeger-gmbh/codabix:latest --run-as-service
```

> NOTE: When running the Codabix image with persisted data (already existing application data from a previous run) overriding the admin password or the project name will have no effect.


### Overriding more settings parameters

It is possible to override the default project settings by passing JSON data via the environment variable `CODABIX_PROJECT_SETTINGS`.

```
docker run -d -p 8181:8181 --env CODABIX_PROJECT_SETTINGS="{'ProjectName': 'My Codabix Project'}" ghcr.io/traeger-gmbh/codabix:latest --run-as-service
```

This way you can e.g. use Codabix in a docker-compose stack with an MySQL back end database:

```
version: "2"
services:
  codabix:
    image: ghcr.io/traeger-gmbh/codabix:latest
    ports:
      - "8181:8181"
    volumes:
      - "codabix-data:/home/codabix/data"
    depends_on:
      - "db"
    environment:
      CODABIX_ADMIN_PASSWORD: StrongAdminPassword
      CODABIX_PROJECT_NAME: My CoDaBix project
      CODABIX_PROJECT_SETTINGS: >- 
        { 'DatabaseMode': 'MySQL',
          'SqlConnection':
            {
              'Hostname': 'db',
              'Database': 'codabix-backend',
              'Username': 'codabix',
              'Password': 'codabix'
            }
        }
    command:  --run-as-service
  db:
    image: mysql:latest
    volumes:
      - "db-data:/var/lib/mysql"
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: codabix-backend
      MYSQL_USER: codabix
      MYSQL_PASSWORD: codabix
volumes:
  codabix-data:
  db-data:
```

## Setting the license code

The license code used by Codabix inside the container is set via the environment variable `CODABIX_LICENSE_CODE`.

**Attention:** This environment variable has been introduced in Codabix v1.0 so it will only work for version upwards.

Example when using __docker run__ (`<your-license-code>` represents your license code here):

```
docker run -d -p 8181:8181 -v codabix-data:/home/codabix/data -e CODABIX_LICENSE_CODE=<your-license-code> ghcr.io/traeger-gmbh/codabix:latest --run-as-service
```

Example when using __docker-compose__ (`<your-license-code>` represents your license code here):

```
version: "2"
services:
  codabix:
    image: ghcr.io/traeger-gmbh/codabix:latest
    ports:
      - "8181:8181"
    volumes:
      - "codabix-data:/home/codabix/data"
    environment:
      CODABIX_ADMIN_PASSWORD: StrongAdminPassword
      CODABIX_PROJECT_NAME: My CoDaBix project
      CODABIX_LICENSE_CODE: <your-license-code>
    command:  --run-as-service
volumes:
  codabix-data:
```

### Setting the license code in a running container

If you want to set the license code for a Codabix container that is already running and which was started without setting the
`CODABIX_LICENSE_CODE` environment variable, you can execute the following command, where `<container>` refers
to the running container's name or ID, and `<your-license-code>` represents your license code:

```
docker exec -u 0 <container> codabix license set <your-license-code>
```

The new license code should be recognized by Codabix a few seconds after running the command.

**Note:** As mentioned above, this only works if you didn't set the `CODABIX_LICENSE_CODE` environment variable when
creating the container.
Additionally, the license will only work in the current container; so e.g. if you update to
a newer Codabix image, you will have to set the license again.

For this reason, using the environment variable to set the license code is preferred.

## Building the image

During the build process the installer of Codabix will be downloaded from https://codabix.com and installed in the image.

### Setting the Codabix version

To choose the Codabix version used in the image two environment variables in the Dockerfile have to be set accordingly:

- VERSION
  - This variable holds the version that shall be used for the image.
- RELEASE_DATE
  - This variable corresponds to the release date of the version set in the VERSION variable.
- Example:
  - For using Codabix v1.3.0 the variables have to be set as follows:
    - ENV VERSION 1.3.0
    - ENV RELEASE_DATE 2021-12-16
