# fundraising-dev

A Docker-based environment for developing and maintaining tools used by the
Wikimedia Foundation for fundraising.

## Building the base images

For the following commands, you can set the GIT_REVIEW_USER environment variable, then just
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

Optionally, set the GIT_REVIEW_USER environment variable (as above). Then, run `./setup.sh`. After that, you
should be able to visit your local payments wiki at https://localhost:9001 (or an alternate port, if you set
one when prompted by the setup script).

## Starting, stopping and rebuilding services

Start all services:

    docker-compose up -d

Stop all services without resetting the containers' internal persistant storage:

    docker-compose stop

Stop all services, remove the containers and internal persistant storage. (Database contents will
persist. This is necessary after a change to the host port in the `.env` file.)

    docker-compose down

To partly or completely rebuild the environment, run `./setup.sh` again.

## Unit tests

For phpunit tests for DonationInterface, run `./phpunit-payments.sh`.

## Logs

Logs should appear magically in the logs directory. Filenames should be self-explanatory. If the logs don't
show up as expected, try `docker-comppose ps` to check that the logger container is running.
