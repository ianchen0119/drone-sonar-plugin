FROM golang:1.19.6-alpine as build
RUN mkdir -p /go/src/github.com/ianchen0119/drone-sonar-plugin
WORKDIR /go/src/github.com/ianchen0119/drone-sonar-plugin 
COPY *.go ./
COPY vendor ./vendor/
RUN GO111MODULE=auto GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o drone-sonar

FROM openjdk:11.0.8-jre

ARG SONAR_VERSION=4.7.0.2747
ARG SONAR_SCANNER_CLI=sonar-scanner-cli-${SONAR_VERSION}
ARG SONAR_SCANNER=sonar-scanner-${SONAR_VERSION}

RUN apt-get update \
    && apt-get install -y nodejs curl \
    && apt-get clean

COPY --from=build /go/src/github.com/ianchen0119/drone-sonar-plugin/drone-sonar /bin/
WORKDIR /bin

RUN curl https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/${SONAR_SCANNER_CLI}.zip -so /bin/${SONAR_SCANNER_CLI}.zip
RUN unzip ${SONAR_SCANNER_CLI}.zip \
    && rm ${SONAR_SCANNER_CLI}.zip 

ENV PATH $PATH:/bin/${SONAR_SCANNER}/bin

ENTRYPOINT /bin/drone-sonar
