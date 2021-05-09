ARG build_version="latest"

# we use always exact version of current stable to find out later
# what is installed
FROM homeassistant/raspberrypi3-homeassistant:2021.4.6

LABEL version="${build_version}" \
      description="Secured configuration of homeassistant for NATHAN@home setup" \
      maintainer="rbe-git@t-online.de"

EXPOSE 4143/tcp

###
# Security and setup changes to standard image
#
#COPY hass.sh /etc/profile.d/hass.sh
#ln -s /run/secrets/HA_SECRETS secrets.yaml

# TODO: switch homeassitant to non-root venv
# see for basic idea: https://github.com/tribut/homeassistant-docker-venv/blob/master/run