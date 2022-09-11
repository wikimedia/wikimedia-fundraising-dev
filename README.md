# fundraising-dev

A Docker-based environment for developing and maintaining tools used by the
Wikimedia Foundation for fundraising.

*FIXME Reorganize, putting more important stuff higher up*

## Building the base images

*FIXME Update now that images are in WMF registry*

(Only necessary for developing on the images themselves.)

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

If you've previously installed docker-pkg, you may wish to pull the latest master via git.
(An important fix was recently merged into the master branch for that tool.)

Clone the dev-images repository and check out the gerrit changes with the setup
for the fundraising-dev images:

    git clone "ssh://${GIT_REVIEW_USER}@gerrit.wikimedia.org:29418/releng/dev-images" && \
        scp -p -P 29418 ${GIT_REVIEW_USER}@gerrit.wikimedia.org:hooks/commit-msg \
        "dev-images/.git/hooks/"
    cd dev-images

You should then be able to build the images for payments, civicrm and the centralized logger,
as follows (from the dev-images directory):

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

If you haven't run `setup.sh` yet, do so before starting the application.


## Creating the environment

First, clone this repository. Optionally, set the `GIT_REVIEW_USER` environment variable (as above).
Then, cd into the root directory of the repository and run `setup.sh`.

Note that normally `setup.sh` *only needs to run once* for each dev environment you set up. It
does *not* need to be run again if you destroy your Docker containers (see below), because it
doesn't change anything inside the containers, just on the host (so the containers are
[ephemeral](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#create-ephemeral-containers)).

What *does* `setup.sh` do? In a nutshell, it downloads source code for Fundraising projects
and runs some setup, all of which creates stuff under the directory of this repository.
It also creates an `.env` file in the root directory of the repository, where we store some
configurable details of your local setup (i.e., the ports you choose for services exposed
to the host, and the user to run the containers as).

If `setup.sh` completes successfully, your dev environment should be up and running! You
should be able to visit your local Payments wiki at
[https://localhost:9001](https://localhost:9001) (unless you chose a different port
for Payments). Civicrm should be at [https://wmff.localhost:32353](https://wmff.localhost:32353).

See the next section for how to stop, start and rebuild the environment.

## Starting, stopping and rebuilding

Warning: Do not modify `docker-compose.yml` or update this repository without
destroying the containers first.

Warning: Run `setup.sh` before starting services.

### Stopping and starting without destorying and recreating containers

Start, restart or stop all services, without deleting the containers or their internal persistant
storage, like this:

    docker-compose start
    docker-compose restart
    docker-compose stop

Just stopping containers, using the last command, above, is the most lightweight way to turn
things off. All of the above commands can also be executed for any of the individual
services specified in `docker-compose.yml`, just by adding the name of the service to the
end of the command. The restart option can be useful to force some programs (apache,
rsyslogd) to reload their configuration.

### Stopping and stopping with destruction and recreation of containers

Here is how to stop all services and destroy the containers and internal storage. (Database,
queue and log contents will persist, since they are stored on the host. Nothing of
importance is stored inside the containers, so doing this won't impact your setup at all.
No need to re-run `setup.sh` afterwards, either.)
*Do this before updating this repository.*

    docker-compose down

Create containers and start all services. Again, *don't* do this before running `setup.sh` for
the first time.

    docker-compose up -d

### Rebuilding stuff with `setup.sh`

To partly or completely rebuild the environment, run `setup.sh` again. Whenever it makes
sense to do so, the script asks for confirmation before performing an action. So,
for example, you can re-run `setup.sh`, skip the step about checking out the source code
to leave the current source code intact, but still reset the database to a fresh state
and re-run `install.php` on Payments. Just answer the corresponding prompts to perform
or skip actions as desired.

## Config

Many configuration files used by the codebases or for dev environment setup are provided under
the `config` directory, for ease of access.

All files under the `config` directory are shared live between the host and the Docker containers. Changes
made to these files on the host are visible immediately to the services running in the containers.
(That is, there's no intermediate "provisioning" or copying step, as there was with Vagrant.)

For example, to modify settings for Payments wiki, just save your changes to
`config/payments/LocalSettings.php` or `config/smashpig/main.yaml`, and reload the page in your browser.

For a few settings under `config`, changes require a container restart to take effect, even though
the changes are visible inside the containers right away. This is just because some processes only
read their configuration files when they start up. This is the case for configurations for Web xdebug
and rsyslog. (See above on how to restart a container.)

### Tracking changes to files under `config`

Most files under the `config` directory are tracked by git as part of the fundraising-dev repo.
You can use git to share config changes with the rest of the team, and to keep your local config
up-to-date.

There are a few files in `config` that are ignored by git. Some&mdash;specifically, xdebug
settings&mdash;are ignored because it seems likely that they'll be unique to each
developer's local setup, so tracking them with git probably wouldn't be useful.

For the Payments and E-mail Preference Center wikis, you can create a custom, untracked
`LocalSettings-local.php` file (in `config/payments`/ and `config/email-pref-ctr`,
respectively). This is the place to add temporary settings that you need for development without
modifying git-tracked files.

Also ignored by this git repo are the private settings, described below. Changes to those
settings can be tracked using the private git repo.

### Container-internal config

Not all configuration is visible outside the containers. A lot of config is baked into the images
or created dynamically by scripts when the containers start up. It is expected that, for the most part,
developers won't need to modify these internal settings. In any case, all config files,
both exposed and container-internal, can be accessed at interal container locations by opening a shell
in a container. (See "Opening a shell", below.) Also note that config that is not exposed outside
the containers is stored on the containers' internal filesystems, so it will be reset when the containers
are re-created. (However, it is also not expected that such container-internal config will
ever need to be customized. If you find yourself frequently opening a shell to modify config
inside a container, that's probably an indication we should change the setup to make that
config available on the host.)

### How config works under-the-hood

All configuration visible outside the containers is shared inside at `/srv/config/exposed/` and appears
on the host in the `config` directory. This sharing is set up via `docker-compose.yml`. Container-internal
config is under `/srv/config/internal/`.

Inside the containers, symlinks are used to provide configuration files to services at appropriate
container-internal locations.

### Private config

See [this task](https://phabricator.wikimedia.org/T266093) for the remote address of the private config
repository. Enter the remote when prompted by `setup.sh`. All private config is located under
`config-private` (and is ignored by this public repository).

## Logs

Logs should appear magically in the `logs` directory. Filenames should be self-explanatory. If the logs don't
show up as expected, try `docker-comppose ps` to check that the logger container is running.

Logs are not yet rotated. If they start getting too big, you can just delete them.

## Unit tests

For phpunit tests for DonationInterface, run `payments-phpunit.sh`.

For phpunit tests for Civicrm, run `civicrm-phpunit.sh wmff`.

## Queues

`queues-redis-cli.sh` provides easy access to `redis-cli` in the queues container. Arguemnts
passed to the script are passed along to command in the container. For example, to monitor
the queues, run `queues-redis-cli.sh monitor`.

## Database

`setup.sh` will ask for a port to expose on the host for the database connection. You can use that
port to connect to the database from the host computer. For the MySQL database host setting,
use 127.0.0.1. You can connect as root database user, without a password. So, for example,
substituting the correct port, the following command can be used to test database access
from the host computer:

    mysql -h 127.0.0.1 -P {exposed_maridb_port} -u root

(Note: If, instead of 127.0.0.1, you specify `localhost` as the database host, you may need
to explicitly tell your MySQL client to connect using TCP.)

The script `database-mysql.sh` opens a mysql shell directly on the database container. Arguments
passed to that script are added to the arguments passed to the command-line client. So,
you can say, for example, `./database-mysql.sh civicrm` to directly access the civicrm database.

## XDebug

By default, debugging is enabled via `xdebug.remote_enable`. `setup.sh` creates web and cli xdebug
configuration files  in the host `config` directory. Note that some xdebug settings (like
`xdebug.remote_server`) are baked into the docker images and probably won't need any tweaking.
However, any settings can be changed via the files in the `config` directory. Re-running `setup.sh` will
reset them to default values and back up any customizations.

For changes in `xdebug-web.ini` to take effect, the payments or civicrm container must be re-started, so Apache
can reload the settings (see below on how to do this). However, changes in `xdebug-cli.ini` don't
require a container restart.

For command-line debugging, it's useful to set `xdebug.remote_autostart` to "on", and set your IDE
to listen for XDebug connections.

Details of each IDE setup may vary. Here are some IDE settings that have been tested with Eclipse:
  - Encoding: ISO-8859-1
  - Path mapping: `/var/www/html/` <-> `src/payments/`

For debugging the debugger, logs are available in `logs/payments-xdebug.log` or
`logs/civicrm-xdebug.log`

If you're running your IDE on a different computer than the Docker application, you can tunnel
both XDebug and Web connections by executing the following command on the host computer where the
Docker application is running (substituting everything in {} with the appropriate values).
TODO: Adapt this command for access to Civicrm and E-mail Preference Center, too.

    ssh -N -L*:{XDBUG_PORT}:localhost:{XDBUG_PORT} \
        -Rlocalhost:{FR_DOCKER_PAYMENTS_PORT}:localhost:{FR_DOCKER_PAYMENTS_PORT} \
        {USER_ON_IDE_BOX}@{IP_OF_IDE_BOX}

Depending on your IDE you may wish to set the environment variable PHP_IDE_CONFIG
For phpstorm it should hold a value like "serverName=wmff" - where wmff is configured
as a deployment server in phpstorm. If you are using drush then the site alias will set
this variable - e.g drush @wmff will run drush in the context of the wmff.localhost
site, including the PHP_IDE_CONFIG.serverName key.

You can set a system default for this variable (or set any other environment variable)
by adding a docker-compose.override.yml - renaming the docker-compose.override.sample.yml will get you started.
Note that the drush environment variables are instantiated per process and override
the system default variable (the override file overrides docker not anything set
at a per process level).

## Opening a shell

Here's how to get a shell in a container (provided it's running). Substitute {service} for any
of the services defined in docker-compose.yml (i.e., payments, civicrm, logger or database).

    docker-compose exec {service} bash

For a root shell, use this command:

    docker-compose exec -u 0 {service} bash

## Serving payments and smashpig services via routable URLs

You may need a routable (non-localhost) URL to test Payments for certain methods (e.g.
Apple Pay) or just to test using different devices. Also, to test SmashPig IPN
listeners, your local SmashPig service needs to be publicly accessible.

Fundraising tech has a Wikimedia Cloud Services project (fr-tech-dev) set up to forward
the URLs paymentstest[1-6].wmcloud.org and paymentsipntest[1-6].wmcloud.org to different
ports on our VPS. You can forward these ports to your local machine using the
proxy-forward.sh script. Consult with FR-Tech to reserve a pair of URLs and a pair of
ports, and enter the corresponding number when setup.sh asks for your proxy forwarding ID.

Note that the script assumes you have a setting in your .ssh/config like the following:

    Host payments.fr-tech-dev
        User <your shell name>
        Hostname %h.eqiad1.wikimedia.cloud
        ProxyJump bastion.wmcloud.org:22
        IdentityFile ~/.ssh/id_rsa

For more info, see [Help accessing Cloud VPS instances](https://wikitech.wikimedia.org/wiki/Help:Accessing_Cloud_VPS_instances).

### Using autossh and a systemd service

autossh is a utility for restarting ssh connections if they fail. If you install autossh on your system,
you can use it to forward ports for your services like this:

    proxy-forward.sh --autossh

On Linux, to set this up as a service managed by your local user, create a file called
~/.config/systemd/user/fr-tunnel.service with the following contents (substituting
{FUNDRAISING-DEV_DIRECTORY} with the full path to your fundraising-dev setup):

    [Unit]
    Description=Tunnels for Fundraising local development

    [Service]
    WorkingDirectory={FUNDRAISING-DEV_DIRECTORY}
    ExecStart={FUNDRAISING-DEV_DIRECTORY}/proxy-forward.sh --autossh
    ExecStop=/bin/kill $MAINPID

    [Install]
    WantedBy=default.target

Then run:

    systemctl --user daemon-reload

After that, you should be able to start and stop the tunnels with the following commands:

    systemctl --user start fr-tunnel.service
    systemctl --user stop fr-tunnel.service

## Docker troubleshooting

Here are some commands for debugging problems with this Docker appliaction.

Check the status of all containers in the application:

    docker-compose ps

Output the logs for all containers in the application:

    docker-compose logs
