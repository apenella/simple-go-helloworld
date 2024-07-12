FROM scratch

ARG listen_port=8080

# set / as working dir
WORKDIR /

# copy the binary into container
COPY ./.bin/simple-go-helloworld_linux_amd64 /simple-go-helloworld

# expose the port where web server is listen to
EXPOSE ${listen_port}

# set binary as entrypoint
ENTRYPOINT ["/simple-go-helloworld"]
