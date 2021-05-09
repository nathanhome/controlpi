### Building the image
```
> docker build --tag nathanhome/assistant:0.1.0 --rm --pull .
```

### Running the container
```
> docker run -d -v /home/homedock/.nathan/homeassistant:/config -v /etc/localtime:/etc/localtime:ro --network home-net -p 443:4143 -e TZ=Europe/Berlin nathanhome/assistant
```