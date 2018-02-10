FROM scratch
MAINTAINER Aleix Penella (aleix.penella [at] gmail.com)

# set / as working dir
WORKDIR /

# copy de binary into container
COPY simple-go-helloworld /

# expose the port where web server is listen to
EXPOSE 80

# set binary as entrypoint
ENTRYPOINT ["/simple-go-helloworld"]