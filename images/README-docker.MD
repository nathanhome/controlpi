## Mosquitto

#### Creating users with password
'''
'''

#### Building Mosquitto image
'''
> docker build --pull --rm -f "images/docker-mosquitto/Dockerfile" -t nathan-mosquitto:0.1.0 "images/docker-mosquitto"
'''

#### Running Mosquitto images
'''
> docker run -p 1883:1883 -p 9001:9001 -v $HOME/.nathan/mosquitto/data:/mosquitto/data -v $HOME/.nathan/mosquitto/logs:/mosquitto/logs nathan-mosquitto:0.1.1
'''

#### Mosquitto commands
Generate user/password
'''
docker exec -it <running container id> /usr/bin/mosquitto_passwd /mosquitto/data/mosquitto.passwd <myuser>
'''
You can then copy the file outsid from the container from the data dir.
We recommend to add the file when building the immutable file.

'''
docker exec -it <running container id> /usr/bin/mosquitto_sub -t test -h localhost < -u user> < -p password>
'''

'''
docker exec -it <running container id> /usr/bin/mosquitto_pub -t test -h localhost < -u user> < -p password> -m "Hello"
'''
