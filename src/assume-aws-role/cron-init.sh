#!/usr/bin/env bash
# This script is intended to be run as root with a container that runs as root (even if you connect with a different user)
# However, it supports running as a user other than root if passwordless sudo is configured for that same user.

set -e 

sudoIf()
{
    if [ "$(id -u)" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

# Wire in codespaces secret processing to zsh if present (since may have been added to image after script was run)
if [ -f  /etc/zsh/zlogin ] && ! grep '/etc/profile.d/00-restore-secrets.sh' /etc/zsh/zlogin > /dev/null 2>&1; then
    echo -e "if [ -f /etc/profile.d/00-restore-secrets.sh ]; then . /etc/profile.d/00-restore-secrets.sh; fi\n$(cat /etc/zsh/zlogin 2>/dev/null || echo '')" | sudoIf tee /etc/zsh/zlogin > /dev/null
fi

# ** Start Cron server **
sudoIf /etc/init.d/cron start 2>&1 | sudoIf tee /tmp/cron.log > /dev/null

set +e
exec "$@"
