FROM golang:1.15.1-buster as ClaatSetup
RUN CGO_ENABLED=0 go get github.com/googlecodelabs/tools/claat

FROM alpine:3.10 as ClaatExporter
WORKDIR /app
COPY --from=ClaatSetup /go/bin/claat /claat
COPY docs/ input/
RUN /claat export -o output input/**/*.md

FROM alpine:3.10 as AppCompiler
RUN apk add --update git nodejs npm make python gcc g++ && \
    npm install -g gulp-cli

WORKDIR /app

RUN git clone -b customization https://github.com/peterpf/tools.git codelabs-tools
WORKDIR /app/codelabs-tools/site

# Install dependencies
RUN npm install && npm install gulp

# Copy exported codelabs from previous stage
COPY --from=ClaatExporter /app/output codelabs/


# Build everything
RUN gulp dist --codelabs-dir=codelabs

# Replace symlink in with actual content (see below for description)
WORKDIR /app/codelabs-tools/site/dist
RUN rm codelabs
COPY --from=ClaatExporter /app/output codelabs/

FROM caddy:alpine as Deployment
WORKDIR /app
COPY --from=AppCompiler /app/codelabs-tools/site/dist/ .
EXPOSE 80
CMD ["caddy", "file-server"]
