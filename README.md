# fundraising-dev

A Docker-based environment for developing and maintaining tools used by the
Wikimedia Foundation for fundraising.

## Building the base images

For the following commands, you can set the `GIT_REVIEW_USER` environment variable, then just
copy and paste the command as-is onto the command line. (Note: the same environment variable is also
used by `setup.sh`.)

Install [docker-pkg](https://doc.wikimedia.org/docker-pkg/):

    git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/operations/docker-images/docker-pkg" && \
        scp -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
        "docker-pkg/.git/hooks/"
    cd docker-pkg
    pip3 install -e .

After installing, check that the `docker-pkg` executable is in your `PATH`. If it's not, you may need to
add `~/.local/bin/` to your `PATH`.

Clone the dev-images repository and check out the gerrit changes with the setup
for the fundraising-dev images:

    git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/releng/dev-images" && \
        scp -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
        "dev-images/.git/hooks/"
    cd dev-images
    git review -d 635361

You should then be able to build the images for payments and the centralized logger, as follows
(from the dev-images directory):

    docker-pkg -c dockerfiles/config.yaml build --no-pull \
        --select 'docker-registry.wikimedia.org/dev/fundraising*:*' dockerfiles/
    
    docker-pkg -c dockerfiles/config.yaml build --no-pull \
        --select 'docker-registry.wikimedia.org/dev/buster-rsyslog*:*' dockerfiles/

Command to check that the new images were created:

    docker image ls

If there's an image appears in the list with no repository or tag, it means an image creation
failed. Check docker-pkg-build.log for details.

If you update the unmerged Gerrit changes and wish to rebuild an image, you may need to remove the
previous build manually:

    docker image rm {image id} -f

(You can find the image id using `docker image ls`.)

Once the [fundraising config](https://gerrit.wikimedia.org/r/c/releng/dev-images/+/632173) has been merged
into the dev-images code repository, and the image has been uploaded to the Docker image repository,
these steps will no longer be necessary. However, these tools will be needed to update the image.

For more information about docker-pkg see the [documentation](https://doc.wikimedia.org/docker-pkg/)
and [instructions for using it for CI images](https://www.mediawiki.org/wiki/Continuous_integration/Docker).

## Creating the environment

Optionally, set the `GIT_REVIEW_USER` environment variable (as above). Then, run `setup.sh`. After that, you
should be able to visit your local payments wiki at https://localhost:9001 (or an alternate port, if you set
one when prompted by the setup script).

Containers will be configured to run as the same user that runs `setup.sh`. This can be changed via the
`.env` file.

## Config

Configurations that seem likely to need tweaking in the course of development work are exposed in the
`config` directory. Most of these configuration files, and others not exposed, can also be accessed at
their standard locations from within the containers. (See "Opening a shell", below.)

## Logs

Logs should appear magically in the logs directory. Filenames should be self-explanatory. If the logs don't
show up as expected, try `docker-comppose ps` to check that the logger container is running.

Logs are not yet rotated. If they start getting too big, you can just delete them.

## Unit tests

For phpunit tests for DonationInterface, run `./phpunit-payments.sh`.

## XDebug

By default, debugging is enabled via `xdebug.remote_enable`. `setup.sh` creates web and cli xdebug
configuration files  in the host `config` directory. Note that some xdebug settings (like
`xdebug.remote_server`) are baked into the docker images and probably won't need any tweaking.
However, any settings can be changed via the files in the `config` directory. Re-running `setup.sh` will
reset them to default values and back up any customizations.

For changes in `xdebug-web.ini` to take effect, the payments container must be re-started, so Apache
can reload the settings (see below on how to do this). However, changes in `xdebug-cli.ini` don't
require a container restart.

For command-line debugging, it's useful to set `xdebug.remote_autostart` to "on", and set your IDE
to listen for XDebug connections.

Details of each IDE setup may vary. Here are some IDE settings that have been tested with Eclipse:
  - Encoding: ISO-8859-1
  - Path mapping: `/var/www/html/` <-> `src/payments/`

For debugging the debugger, logs are available in `logs/payments-xdebug.log`.

If you're running your IDE on a different computer than the Docker application, you can tunnel
both XDebug and Web connections by executing the following command on the host computer where the
Docker application is running (substituting everything in {} with the appropriate values).

    ssh -N -L*:{XDBUG_PORT}:localhost:{XDBUG_PORT} \
        -Rlocalhost:{FR_DOCKER_PAYMENTS_PORT}:localhost:{FR_DOCKER_PAYMENTS_PORT} \
        {USER_ON_IDE_BOX}@{IP_OF_IDE_BOX}

## Opening a shell

Here's how to get a shell in a container (provided it's running). Substitute {service} for any
of the services defined in docker-compose.yml (i.e., payments, logger or database).

    docker-compose exec {service} bash

For a root shell, use this command:

    docker-compose exec -u 0 {service} bash

## Starting, stopping and rebuilding

Start all services, or, if they're already running, rebuild any containers that need updating.
(This is necessary for any changes to the `.env` file to take effect.)

    docker-compose up -d

Stop all services without deleting the containers or their internal persistant storeage:

    docker-compose stop

Stop all services, remove the containers and internal storage. (Database contents will
persist, since they are stored on the host, in the `dbdata` directory.)

    docker-compose down

Restart a service:

    docker-compose restart {service}

To partly or completely rebuild the environment, run `setup.sh` again.

## Docker issues

Here are some commands for debugging problems with this Docker appliaction.

Check the status of all containers in the application:

    docker-compose ps

Output the logs for all containers in the application:

    docker-compose logs
