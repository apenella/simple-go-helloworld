FROM scratch
MAINTAINER Aleix Penella (aleix.penella [at] gmail.com)

# set / as working dir
WORKDIR /

# copy the binary into container
COPY ./.bin/simple-go-helloworld_linux_amd64 /simple-go-helloworld
COPY ./.bin/simple-go-helloworld_linux_amd64_version_commit /
COPY ./.bin/simple-go-helloworld_linux_amd64_version_semver /

# expose the port where web server is listen to
EXPOSE 8080

# set binary as entrypoint
ENTRYPOINT ["/simple-go-helloworld"]