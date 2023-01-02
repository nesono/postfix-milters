#!/bin/bash
# TODO: enable this before push
#set -o errexit -o pipefail -o nounset

# script to create a directory under /vhome/users for each mail account,
# populate the spam db with sa-learn, and fix the permissions of the dir.

# get all mail accounts
echo "sa_learn: Learning Spam from user folders"
if [[ -n "$(ls -A /var/mail/ 2>/dev/null)" ]]; then
  for dir in /var/mail/*; do
    mailaccount="${dir##*/}"
    echo "sa_learn: Creating dir for ${mailaccount}"
    spamdbpath="/vhome/users/${mailaccount}/spamassassin/"
    mkdir -p "${spamdbpath}"

    junkfolder="${dir}/.Junk"
    if [ -d "${junkfolder}" ]; then
      echo "sa_learn: Learning Spam from ${junkfolder} for user ${mailaccount}"
      sa-learn --spam --dbpath "${spamdbpath}/bayes" --progress "${junkfolder}"
      sa-learn --sync
    else
      echo "sa_learn: No Junk folder found - skipping"
    fi

    hamfolder="${dir}/.Archive"
    if [ -d "${hamfolder}" ]; then
      echo "sa_learn: Learning Ham from ${hamfolder} for user ${mailaccount}"
      sa-learn --ham --dbpath "${spamdbpath}/bayes" --progress "${hamfolder}"
      sa-learn --sync
    else
      echo "sa_learn: No Archive folder found - skipping"
    fi
  done
else
  echo "sa_learn: No accounts found! Skipping user learning"
fi

echo "sa_learn: Running the Spamassassin Cronjob"
/etc/cron.daily/spamassassin

echo "sa_learn: Sleeping for a day"
sleep 86400
