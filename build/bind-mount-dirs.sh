# Docker automatically creates any missing bind-mount source directories (local directories) on the host
# defined in our docker-compose files, setting their owner as root. To avoid permission issues for non-root
# processes inside containers, we should preemptively create all bind-mount source directories with the
# correct permissions before container startup.
mkdir -p ./config/
mkdir -p ./src/payments/
mkdir -p ./src/donut/
mkdir -p ./src/privatebin/
mkdir -p ./src/email-pref-ctr/
mkdir -p ./src/civi-sites/
mkdir -p ./src/civicrm-buildkit/
mkdir -p ./src/smashpig/
mkdir -p ./src/civiproxy/
mkdir -p ./src/tools/
mkdir -p ./logs/