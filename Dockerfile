FROM alpine:3.10.3
LABEL maintainer="kalaksi@users.noreply.github.com"

# Only allow patch/minor-version updates to keep things more stable. These are overridable in the
# build-phase. I'll update these from time to time and bump the version if mezzanine gets updated.
ARG GUNICORN_VERSION=">=19.0.0,<20.0.0"
ARG MEZZANINE_VERSION=">=4.3.0,<4.4.0"
ARG PYTHON_LDAP_VERSION=">=3.2.0,<3.3.0"
ARG DJANGO_AUTH_LDAP_VERSION=">=1.7.0,<1.8.0"
ARG PSYCOPG2_VERSION=">=2.8.0,<2.9.0"

# Set the Mezzanine project's name (mandatory).
# Configuring the project is done by modifying the local_settings.py file, as usual.
ENV MEZZANINE_PROJECT=""
ENV GUNICORN_WORKERS="2"
ENV GUNICORN_PORT="8000"

ENV MEZZANINE_UID="78950" MEZZANINE_GID="78950"

# By default, the gunicorn server is run. It's assumed you have an existing mezzanine project
# set up. If you don't, you'll have to create one.
# A quick guide is available at: https://hub.docker.com/kalaksi/mezzanine.

RUN apk add --no-cache --virtual=build-deps \
      gcc \
      jpeg-dev \
      python2-dev \
      python3-dev \
      openldap-dev \
      musl-dev \
      postgresql-dev \
      zlib-dev && \
    apk add --no-cache --virtual=run-deps \
      python3 \
      jpeg \
      postgresql-libs \
      su-exec && \
    pip3 --no-cache-dir install --upgrade setuptools pip && \
    pip3 --no-cache-dir install --upgrade \
      mezzanine${MEZZANINE_VERSION} \
      psycopg2${PSYCOPG2_VERSION} \
      gunicorn${GUNICORN_VERSION} \
      python-ldap${PYTHON_LDAP_VERSION} \
      django-auth-ldap${DJANGO_AUTH_LDAP_VERSION} && \
    apk del --no-cache --purge build-deps

# Use standard directories to better show the intention and keep things ordered.
RUN mkdir -p /srv/mezzanine /etc/nginx/conf.d && \
    touch /etc/nginx/conf.d/mezzanine.conf && \
    chown "${MEZZANINE_UID}:${MEZZANINE_GID}" /srv/mezzanine /etc/nginx/conf.d/mezzanine.conf

# Add simple configuration template for nginx. Configurations are generated to the usual nginx
# conf.d directory so it's simpler to use volumes for sharing the configuration with an
# nginx-container.
COPY nginx.conf.tpl /etc/nginx/mezzanine.conf.tpl

EXPOSE 8000
USER ${MEZZANINE_UID}:${MEZZANINE_GID}

# You should mount a volume over /srv/mezzanine
WORKDIR /srv/mezzanine
CMD set -eu; \
    # Provide some help for the user
    [ -z "$MEZZANINE_PROJECT" ] && (echo "MEZZANINE_PROJECT has to be defined!" >&2; exit 1); \
    cd "$MEZZANINE_PROJECT" || (echo "Failed to descend into project directory. Does it exist?" >&2; exit 1); \
    # Generate nginx-configuration.
    # NOTE: since this container can modify that configuration file by default, it could provide
    # a way for this container to affect the container running nginx. For extra security, you can
    # change the file ownership to root, for example.
    sed -r "s/MEZZANINE_PROJECT/$MEZZANINE_PROJECT/g" /etc/nginx/mezzanine.conf.tpl > "/etc/nginx/conf.d/mezzanine.conf" || echo "Failed to generate Nginx configuration! Skipping." >&2; \
    exec gunicorn -b "0.0.0.0:${GUNICORN_PORT}" -w "$GUNICORN_WORKERS" "${MEZZANINE_PROJECT}.wsgi"
