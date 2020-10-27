# SSL Certificate expiration check
This simple script checks for SSL certificates about to expire and optionally sends an email if the check fails.

## Using
Check the expiration of a certificate like this:

    docker run -e DOMAINS=example.com mobilejazz/certcheck

Configuration variables:
 
 * `MARGIN_DAYS`: how many days of margin you want before getting a warning for a certificate about to expire (default 6)
 * `DOMAINS`: list of domains to verify separated by spaces (for example: `example.com anotherdomain.com`). Either `DOMAINS` or `DOMAINS_FILE` must be provided (and only one of the two).
 * `DOMAINS_FILE`: a file containing the domains to check (for example: `domains.txt`). Either `DOMAINS` or `DOMAINS_FILE` must be provided (and only one of the two).
 * `MAIL_TO`: email to send notifications to (default: none). You will need to configure msmtp by providing an `/etc/msmtprc` file

You can see a more complex usage example in `docker-compose.yml`, which configures msmtp to send mail using Amazon SES and checks a list of domains periodically using the `funkyfuture/deck-chores` image.

## Building
If you want to edit the image, you can rebuild it like this:

    docker build -t mobilejazz/certcheck .