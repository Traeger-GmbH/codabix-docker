FROM ubuntu:18.04 as base

FROM base as builder

ENV CODABIX_DOWNLOAD_LINK https://www.codabix.com/_media/downloads/installers/codabix-0.23.3/codabix-linux-x64-2020-10-19-0.23.3.setup
ENV CODABIX_SETUP_FILE /tmp/codabix.setup
RUN apt-get update && apt-get install -y \
    curl
RUN mkdir -p /home/scripts/
RUN mkdir -p /tmp/codabix
RUN curl ${CODABIX_DOWNLOAD_LINK} --output ${CODABIX_SETUP_FILE}

COPY ./scripts/extract.sh /home/scripts/extract.sh

RUN chmod +x /home/scripts/extract.sh \
    && /home/scripts/extract.sh ${CODABIX_SETUP_FILE}

FROM base

RUN apt-get update && apt-get install -y \
    libicu60 \
    libssl1.1 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/traeger/codabix \
    && mkdir -p /home/scripts

COPY --from=builder /tmp/codabix/* /opt/traeger/codabix/
COPY ./scripts/start.sh /home/scripts

RUN ln -sf /opt/traeger/codabix/CoDaBix-Shell /bin/codabix \
    && chmod +x /home/scripts/start.sh

EXPOSE 8181

RUN groupadd -g 999 codabix && \
    useradd -m -d /home/codabix -r -u 999 -g codabix codabix
RUN mkdir /home/codabix/data && chown -R 999:999 /home/codabix
VOLUME /home/codabix/data
USER codabix

ENTRYPOINT [ "/home/scripts/start.sh" ]
