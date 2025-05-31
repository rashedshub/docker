ARG BASE_TAG="latest"

#
# Firefly III is built from fireflyiii/base (either :develop or :latest).
# For more information about fireflyiii/base visit https://github.com/firefly-iii/base-image/
#

FROM fireflyiii/base:${BASE_TAG}

#
# These arguments are used to set the labels.
#

ARG version
ENV VERSION=$version

ARG isodate
ENV ISODATE=$isodate

ARG gitrevision
ENV GITREVISION=$gitrevision

#
# The health check of this container.
#
HEALTHCHECK --start-period=5m --interval=5s --timeout=3s --retries=3 \
    CMD [ "sh", "-c", "curl --insecure --silent --location --show-error --fail http://localhost:8080$HEALTHCHECK_PATH || exit 1" ]


#
# Some static labels to identify this image.
#
LABEL org.opencontainers.image.authors="James Cole <james@firefly-iii.org>" org.opencontainers.image.url="https://github.com/firefly-iii/docker" org.opencontainers.image.documentation="https://docs.firefly-iii.org/" org.opencontainers.image.source="https://dev.azure.com/Firefly-III/_git/MainImage" org.opencontainers.image.vendor="James Cole <james@firefly-iii.org>" org.opencontainers.image.licenses="AGPL-3.0-or-later" org.opencontainers.image.title="Firefly III" org.opencontainers.image.description="Firefly III - personal finance manager" org.opencontainers.image.base.name="docker.io/fireflyiii/base:latest"

#
# Some dynamic labels to identify this image. They are updated every run.
#

LABEL org.opencontainers.image.created="${ISODATE}"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.revision="${GITREVISION}"

#
# Copy the necessary startup scripts into place.
#
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY counter.txt /var/www/counter-main.txt
COPY date.txt /var/www/build-date-main.txt

#
# Switch to the root user, make the entrypoint script executable, and switch back
# to the default www-data user.
#

USER root
RUN chmod uga+x /usr/local/bin/entrypoint.sh
USER www-data

#
# Copy download.zip to the /var/www directory. During build time, the latest version of Firefly III 
# is downloaded into download.zip.
#

COPY download.zip /var/www/download.zip

#
# Extract Firefly III and make sure the relevant paths have the necessary access rights.
#

RUN unzip -q /var/www/download.zip -d $FIREFLY_III_PATH && \
	chmod -R 775 $FIREFLY_III_PATH/storage && \
	rm /var/www/download.zip

#
# Copy alerts.json into Firefly III. It may contain last-minute security alerts.
#

COPY alerts.json /var/www/html/resources/alerts.json

#
# Done!
#
