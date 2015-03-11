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

# SSH key
RUN mkdir -p /root/.ssh
ADD docker/ssh /root/.ssh
RUN chmod 700 /root/.ssh/id_rsa

```

## Sample for `setup.sh`

``` sh
#!/bin/bash
cd $APP_ROOT
composer install --no-interaction --prefer-dist
```