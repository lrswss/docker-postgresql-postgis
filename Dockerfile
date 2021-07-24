FROM debian:buster-slim
MAINTAINER Lars Wessels <docker@bytebox.org>

ENV POSTGRES_MAJOR_VERSION 11
ENV POSTGIS_MAJOR_VERSION 2.5
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update --fix-missing; \
    apt-get -qq --yes upgrade; \
    apt-get -y --no-install-recommends install \
       ca-certificates apt-transport-https apt-utils wget \
       netcat xz-utils util-linux inetutils-ping nano

# need to at least "en_US.UTF-8" locale for postgres
RUN grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
    sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
    ! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
    apt-get update; apt-get install -y --no-install-recommends locales; \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen; /usr/sbin/locale-gen; \
    update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN apt-get install -y --no-install-recommends \
       postgresql-client-${POSTGRES_MAJOR_VERSION} \
       postgresql-${POSTGRES_MAJOR_VERSION}-postgis-${POSTGIS_MAJOR_VERSION} \
       postgresql-${POSTGRES_MAJOR_VERSION}-postgis-${POSTGIS_MAJOR_VERSION}-scripts

RUN apt-get -y --purge autoremove; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /docker-entrypoint-initdb.d
COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
COPY install-postgis.sh /var/lib/postgresql/
RUN chmod 755 /var/lib/postgresql/install-postgis.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
VOLUME /var/lib/postgresql

STOPSIGNAL SIGINT
EXPOSE 5432
CMD ["postgres"]
