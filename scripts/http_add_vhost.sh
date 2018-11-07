#!/bin/bash
#    Create the correct DocumentRoot directory.
vhost=$(echo $1 | cut -d'.' -f1)
echo $vhost
domain=$(echo $1 | cut -d'.' -f2-)
echo $domain

if [ "$domain" == "bjarne-huijs.sb.uclllabs.be" ]; then
	if ! [[ "$vhost" =~ [^a-zA-Z0-9]+ ]]; then
		mkdir -p /var/www/$vhost/public_html
		#    Configure vhost specific logging.
		touch /etc/apache2/sites-available/$vhost.conf
		echo "<VirtualHost *:80>
	ServerAdmin admin@bjarne-huijs.sb.uclllabs.be
	ServerName $vhost.bjarne-huijs.sb.uclllabs.be
        DocumentRoot /var/www/$vhost/public_html

        ErrorLog /var/www/$vhost/apache.error.log
        CustomLog /var/www/$vhost/apache.access.log combined
        php_flag log_errors on
        php_flag display_errors on
        php_value error_reporting 2147483647
        php_value error_log /var/www/$vhost/php.error.log
</VirtualHost>" >> /etc/apache2/sites-available/$vhost.conf
		#    Create a default index.html page.
		touch /var/www/$vhost/public_html/index.html
		echo "<html>
  <head>
    <title>Home vhost $vhost</title>
  </head>
  <body>
    <h1>welcome</h1>
    <p>this is the default page of vhost $vhost</p>
  </body>
</html>" >> /var/www/$vhost/public_html/index.html
		#    Enable the vhost.
		#    Refuse to create a vhost for a non-existing domain.
		dns_add_record -t A $vhost 193.191.177.134 $domain
		a2ensite $vhost.conf
		systemctl reload apache2
	else
		echo "Vhost name not correctly formatted, please use only letters and numbers"
	fi
else
	echo "Wrong domain given, please try again"
fi