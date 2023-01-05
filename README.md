# Postfix-Milters

Postfix milters in Docker container - communicating through sockets with the postfix SMTP server.

## Configuration

Use the following environment variables to specify the path of each socket below `/var/spool/postfix`.
Note that the Postfix container needs to be in sync with these paths.

Make sure to mount the following volumes for each corresponding service:

* `/var/spool/postfix` - required for milter to postfix communication
* `/var/mail` - the main folder containing all mailboxes for all users for learning from Junk folders

### Spamass-Milter

Please make sure to specify the socket path for the spamass-milter socket as an environment variable.

* `SPAMASS_SOCKET_PATH`

In case you want to learn spam and have spamassassin adapt to your classifications, make sure to mount 
the following volume.

* `/vhome/users/` - persisting learned Spam data

### Postgrey Milter

Please make sure to specify the socket path for the postgrey milter socket as an environment variable.

* `POSTGREY_SOCKET_PATH`

### OPENDKIM Milter

Create a DKIM txt and key file using the following command.

```bash
opendkim-genkey -t -s 2023-01-04 -d nesono.com,issing.link,noerpel.net,frankfriedbert.de,byorkesterbaritone.com
```

Please make sure to specify the socket path for the opendkim milter socket as an environment variable.

* `DKIM_SOCKET_PATH`
* `DKIM_SELECTOR`
* `DKIM_DOMAINS`

Also make sure to make the key available to opendkim. For that, either mount a volume with the required keys
(either to this mount point or as a docker secret) and make sure to set the environment variable to tell `opendkim`
to use the keys or copy the key in differently and point to it via the environment variable.

* (Optional) Volume: `/etc/opendkim/keys`
* Environment variable: `DKIM_KEY_PATH`

### OPENDMARC Milter

Make sure to set the following environment variables.

* `DMARC_SOCKET_PATH`, e.g. `private/dmarc`
* `MAIL_HOSTNAME`, e.g. `smtp.nesono.com`

Make sure you tell Postfix where to find the socket.
