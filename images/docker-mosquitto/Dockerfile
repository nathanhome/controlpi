ARG build_version="latest"

FROM eclipse-mosquitto:2.0.10-openssl

LABEL version="${build_version}" \
      maintainer="rbe-git@t-online.de" \
      description="Mosquitto broker configured for NATHAN home automation"

# config is always part of the immutable image
COPY mosquitto.conf  /mosquitto/config/mosquitto.conf

EXPOSE 8883



