## Mosquitto

#### Creating users with password
'''
'''

#### Prerequisite: generate passwd file using eclipse-mosquitto plain base container
Generate user/password
```
> docker run -p 1883:1883 -p 9001:9001 -v $HOME/.nathan/mosquitto/data:/mosquitto/data -v $HOME/.nathan/mosquitto/logs:/mosquitto/logs eclipse-mosquitto:1.6
> docker exec -it <running container id> /usr/bin/mosquitto_passwd -c /mosquitto/data/mosquitto.passwd <myfirstuser>
```
Take care that you do not rebuild the passwd file afterwards and only use:
```
> docker exec -it <running container id> /usr/bin/mosquitto_passwd /mosquitto/data/mosquitto.passwd <myseconduser>
```


#### Building Mosquitto image
```
> docker build --pull --rm -t nathanhome/mosquitto:0.1.0 .
```

```
NATHAN_BUILD_VERSION=0.x.xx docker-compose --project-name nathanhome build --force-rm --pull
```

#### Running Mosquitto images
```
NATHAN_BUILD_VERSION=0.x.xx docker-compose --project-name nathanhome up -d
```


#### Test MQTT setup from commandline with Docker
```
docker exec -it <running container id> /usr/bin/mosquitto_sub -t test -h localhost < -u user> < -P password>
```

```
docker exec -it 97abac7e3532 /usr/bin/mosquitto_pub -t test -h mosquitto --cafile /mosquitto/data/nathan-mqtts.rederlechner.home-chain.pem -L "mqtts://zwaver:#run4#W4ve-88319+Rider@mqtts.home/test" -m "Hello" -d

docker exec -it <running container id> /usr/bin/mosquitto_pub -t test -h mosquitto --cafile /mosquitto/data/nathan-mqtts.rederlechner.home-chain.pem -u homeassi -P "-2R3d-4_H0me#Ctrl_19761" -m "Hello"
```
