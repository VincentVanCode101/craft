FROM maven:3.9.6-eclipse-temurin-21-jammy AS dev

WORKDIR /workspace

COPY ./pom.xml ./

RUN mvn dependency:go-offline

RUN apt-get update && apt-get install -y make

COPY src/ ./src/
COPY Makefile Makefile

RUN make build
RUN make test
