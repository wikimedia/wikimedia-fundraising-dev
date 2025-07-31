<?php
/* Apache Virtual Host Template
 *
 * @var string $root - the local path to the web root
 * @var string $host - the hostname to listen for
 * @var int $port - the port to listen for
 * @var string $include_vhost_file - the local path to a related config file
 * @var string $visibility - which interfaces the vhost is available on
 */

?>

<VirtualHost *:9001>
    ServerAdmin webmaster@<?php echo $host ?>

    DocumentRoot "<?php echo $root ?>"

    ServerName <?php echo $host ?>

    <?php if ($host == "wmff.localhost") { ?>
    ServerAlias wmff.civicrm
    <?php } ?>
	<?php if ($host == "wmf.localhost") { ?>
    ServerAlias wmf.civicrm
	<?php } ?>

    ErrorLog "| /usr/bin/logger -thttpd -plocal6.err"
    CustomLog "| /usr/bin/logger -thttpd -plocal6.notice" combined

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/docker-ssl.pem
    SSLCertificateKeyFile /etc/ssl/private/docker-ssl.key

    <Directory "<?php echo $root ?>">
        Options All
        AllowOverride All
        <IfModule mod_authz_host.c>
            Require <?php echo $visibility ?> granted
        </IfModule>
    </Directory>

    <?php if (!empty($include_vhost_file)) { ?>
    Include <?php echo $include_vhost_file ?>
    <?php } ?>

</VirtualHost>
