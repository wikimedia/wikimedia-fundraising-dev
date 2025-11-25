#!/bin/bash
# Note: the edit.php script takes the page content on stdin and outputs
# some text. We use < to redirect the file contents into the stdin of
# "docker compose exec" from the external machine rather than trying
# to wrap the exec subarguments in layers of "sh -c" or the like.
# The -T argument to exec suppresses a 'the input device is not a TTY'
# warning.
docker compose exec -T -w "/var/www/html/" \
	payments php maintenance/edit.php Main_Page < config/payments/Main_Page.wiki
docker compose exec -T -w "/var/www/html/" \
	payments php maintenance/edit.php Donate-error < config/payments/Donate-error.wiki
docker compose exec -T -w "/var/www/html/" \
	payments php maintenance/edit.php Donate-thanks < config/payments/Donate-thanks.wiki
docker compose exec -T -w "/var/www/html/" \
	payments php maintenance/edit.php Template:LanguageSwitch < config/payments/LanguageSwitch.wiki
docker compose exec -T -w "/var/www/html/" \
	payments php maintenance/edit.php Template:2011FR/JimmyQuote/text/en < config/payments/Appeal.wiki
docker compose exec -T -w "/var/www/html/" \
	payments php maintenance/edit.php Template:2011FR/WP25/text/en < config/payments/Appeal-WP25.wiki
docker compose exec -T -w "/var/www/html/" \
	payments php maintenance/edit.php Template:2011FR/WP25/text/es-419 < config/payments/Appeal-WP25.es-419.wiki
docker compose exec -T -w "/var/www/html/" \
	payments php maintenance/edit.php Template:2011FR/WP25/text/fr < config/payments/Appeal-WP25.fr.wiki
docker compose exec -T -w "/var/www/html/" \
	payments php maintenance/edit.php Template:2011FR/WP25/text/pt-br < config/payments/Appeal-WP25.pt-br.wiki
