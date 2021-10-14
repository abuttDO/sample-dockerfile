# This is a standard Dockerfile for building a Go app.
# It is a multi-stage build: the first stage compiles the Go source into a binary, and
#   the second stage copies only the binary into an alpine base.

# -- Stage 1 -- #
# Compile the app.
FROM golang:1.12-alpine as builder
WORKDIR /app
RUN mkdir -p public
RUN ls -ltrh
#RUN mkdir -p /app/public
# The build context is set to the directory where the repo is cloned.
# This will copy all files in the repo to /app inside the container.
# If your app requires the build context to be set to a subdirectory inside the repo, you
#   can use the source_dir app spec option, see: https://www.digitalocean.com/docs/app-platform/references/app-specification-reference/
COPY . .
RUN go build -mod=vendor -o bin/hello
ARG DATABASE_URL
ARG CA_CERT
# -- Stage 2 -- #
# Create the final environment with the compiled binary.
FROM alpine
# Install any required dependencies.
RUN apk --no-cache add ca-certificates
WORKDIR /root/

ENV CA_CERT=${CA_CERT}
RUN echo $CA_CERT


ENV DATABASE_URL=${DATABASE_URL}
RUN echo $DATABASE_URL
#RUN mkdir -p /root/public

# Copy the binary from the builder stage and set it as the default command.
COPY --from=builder /app/bin/hello /usr/local/bin/
CMD ["hello"]
