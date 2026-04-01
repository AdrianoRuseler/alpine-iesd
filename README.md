# alpine-iesd
Interactive Explanations for Semiconductor Devices.

- https://www-g.eng.cam.ac.uk/mmg/teaching/linearcircuits/
- https://www-g.eng.cam.ac.uk/mmg/teaching/

Michael Khaw has been revising and expanding these animations, including the p-n diode, n-Channel JFETs, p-channel JFETs, and n-channel enhancement MOSFETs. 

- http://www-g.eng.cam.ac.uk/mmg/teaching/michaelkhaw/pndiode/loader.html
- http://www-g.eng.cam.ac.uk/mmg/teaching/michaelkhaw/nJFET/loader.html
- http://www-g.eng.cam.ac.uk/mmg/teaching/michaelkhaw/pJFET/loader.html
- http://www-g.eng.cam.ac.uk/mmg/teaching/michaelkhaw/mosfet/loader.html

# Docker Build

```bash
docker build -t alpine-iesd:latest .
```

## Docker HUB

- https://hub.docker.com/r/ruseler/alpine-iesd

```bash
docker build -t ruseler/alpine-iesd:latest .
```


## Run docker compose

```yml
services:
  alpine-iesd:
    image: ruseler/alpine-iesd:latest
    container_name: alpine-iesd
    ports:
      - "8080:80"
    restart: unless-stopped
```

```bash
# Build and start
docker-compose up -d
```

- http://localhost:8080/


```bash
# Stop
docker-compose down
```


