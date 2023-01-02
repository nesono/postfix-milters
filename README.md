# Postfix-Milters

Postfix milters in Docker container - communicating through sockets with the postfix SMTP server.

## Configuration

Use the following environment variables to specify the path of each socket below `/var/spool/postfix`.
Note that the Postfix container needs to be in sync with these paths.

* `SPAMASS_SOCKET_PATH`
* `POSTGREY_SOCKET_PATH`
* `DKIM_SOCKET_PATH` (currently not implemented)

Make sure to mount the following volumes for each corresponding service:

* `/var/spool/postfix` - required for milter to postfix communication
* `/etc/opendkim/keys` - required if opendkim is used
* `/vhome/users/` - persisting learned Spam data
* `/var/mail` - the main folder containing all mailboxes for all users for learning from Junk folders