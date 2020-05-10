FROM eclipse-mosquitto:1.6.9

LABEL maintainer="Bernd Rederlechner <brederle.git@magenta.de>" \
    description="Mosquitto broker configured for NATHAN home automation"

# config is always part of the immutable image
COPY mosquitto.conf  /mosquitto/config/mosquitto.conf

# cadd an immutable user/password setup
COPY mosquitto.passwd /etc/mosquitto/passwd





