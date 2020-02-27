FROM ubuntu:latest as base
ENV CODABIX_SETUP_FILE /tmp/codabix.setup


FROM base as builder

ENV CODABIX_DOWNLOAD_LINK https://www.codabix.com/_media/downloads/installers/codabix-0.21.50/codabix-linux-x64-2020-02-20-0.21.50.setup

ENV CODABIX_SETUP_FILE /tmp/codabix.setup

RUN apt-get update && apt-get install -y \
    curl

RUN curl ${CODABIX_DOWNLOAD_LINK} --output ${CODABIX_SETUP_FILE}

FROM base

RUN apt-get update && apt-get install -y \
    libicu60 \
    libssl1.1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder ${CODABIX_SETUP_FILE} ${CODABIX_SETUP_FILE}

RUN mkdir /home/scripts
COPY ./scripts/start.sh /home/scripts
COPY ./scripts/install.sh /home/scripts
RUN chmod +x /home/scripts/start.sh
RUN chmod +x /home/scripts/install.sh

RUN /home/scripts/install.sh ${CODABIX_SETUP_FILE}
RUN rm ${CODABIX_SETUP_FILE} && rm /home/scripts/install.sh

EXPOSE 8181

RUN groupadd -g 999 codabix && \
    useradd -m -d /home/codabix -r -u 999 -g codabix codabix
RUN mkdir /home/codabix/data && chown -R 999:999 /home/codabix
VOLUME /home/codabix/data
USER codabix

ENTRYPOINT [ "/home/scripts/start.sh" ]
