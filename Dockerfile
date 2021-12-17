FROM ubuntu:hirsute-20210711 as base

FROM base as builder

ARG TARGETPLATFORM

ENV CODABIX_SETUP_FILE /tmp/codabix.setup
ENV VERSION 1.3.0
ENV RELEASE_DATE 2021-12-16

RUN apt-get update && apt-get install -y \
    curl
RUN mkdir -p /home/scripts/

COPY ./scripts/download.sh /home/scripts/download.sh
RUN chmod +x /home/scripts/download.sh \
    && /home/scripts/download.sh -p ${TARGETPLATFORM} -v ${VERSION} -d ${RELEASE_DATE} -o ${CODABIX_SETUP_FILE}

COPY ./scripts/extract.sh /home/scripts/extract.sh

RUN chmod +x /home/scripts/extract.sh \
    && /home/scripts/extract.sh ${CODABIX_SETUP_FILE}

FROM base

RUN apt-get update && apt-get install -y \
    libicu67 \
    libssl1.1 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/traeger/codabix \
    && mkdir -p /home/scripts

COPY --from=builder /tmp/codabix/ /opt/traeger/codabix/
COPY ./scripts/start.sh /home/scripts

RUN ln -sf /opt/traeger/codabix/codabix /bin/codabix \
    && chmod +x /home/scripts/start.sh

EXPOSE 8181

RUN groupadd -g 999 codabix && \
    useradd -m -d /home/codabix -r -u 999 -g codabix codabix
RUN mkdir /home/codabix/data && chown -R 999:999 /home/codabix
VOLUME /home/codabix/data
USER codabix

ENTRYPOINT [ "/home/scripts/start.sh" ]
