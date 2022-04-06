docker-compose exec smashpig php /srv/smashpig/Maintenance/ConsumePendingQueue.php
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush -v ctqc
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush -v piqc
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush -v afqc
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush -v qc
docker-compose exec -w "/srv/civi-sites/wmff/drupal" civicrm drush -v rqc
