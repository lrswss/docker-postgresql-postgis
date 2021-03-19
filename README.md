### Dockerfile for PostgreSQL 11 with Postgis 2.5

I needed a recent PostgresSQL/Postgis image to run on a Raspberry Pi and Banana Pi. Unfortunately Docker-Hub didn't offer anything suitable. Since rebuilding existing Postgis Dockerfiles based on Alpine Linux failed for ARM plattforms, I resorted to use a standard Debian Buster slim base image. Please note that the resulting image is signicifcantly larger (uncompressed about 450 MB) than simliar Postgis images for amd64.

[https://hub.docker.com/repository/docker/bettwanze/postgis](https://hub.docker.com/repository/docker/bettwanze/postgis)
