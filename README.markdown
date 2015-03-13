# A Simple Docker Configuration

``` docker
############################################################
# Sample child dockerfile
############################################################

FROM bowlingx/docker-nginx-php
MAINTAINER David Heidrich (me@bowlingx.com)

# Prepare setup files
RUN mkdir -p /etc/my_init.d
ADD setup.sh /etc/my_init.d/setup.sh
RUN chmod +x /etc/my_init.d/setup.sh

# SSH key, will copy ssh keys found in folder docker (relative to Dockerfile) to container
# Use to access private repositories that have been setup in your composer.json
RUN mkdir -p /root/.ssh
ADD docker/ssh /root/.ssh
RUN chmod 700 /root/.ssh/id_rsa

```

## Sample for `setup.sh`

This file will be executed after machine boot.
``` sh
#!/bin/bash
cd $APP_ROOT
composer install --no-interaction --prefer-dist
```

## Build a new Version
- `docker build -t="bowlingx/docker-nginx-php" .`
- `docker push bowlingx/docker-nginx-php`