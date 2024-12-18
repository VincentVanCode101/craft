FROM maven:3.9.6-eclipse-temurin-21 AS builder

ARG UID=1000
ARG GID=1000
ARG GROUP_ID=com.main
ARG ARTIFACT_ID=default-project-name

WORKDIR /build-space

RUN mvn archetype:generate \
    -DgroupId=${GROUP_ID} \
    -DartifactId=${ARTIFACT_ID} \
    -DoutputDirectory=. \
    -DarchetypeArtifactId=maven-archetype-quickstart \
    -DinteractiveMode=false

RUN chown -R 1000:1000 /build-space

CMD ["tail", "-f", "/dev/null"]