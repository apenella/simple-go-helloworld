FROM scratch
MAINTAINER Aleix Penella (aleix.penella [at] gmail.com)

# set / as working dir
WORKDIR /

# copy the binary into container
COPY ./.bin/simple-go-helloworld_linux_amd64 /
COPY ./.bin/simple-go-helloworld_linux_amd64_version /

# expose the port where web server is listen to
EXPOSE 80

# set binary as entrypoint
ENTRYPOINT ["/simple-go-helloworld"]